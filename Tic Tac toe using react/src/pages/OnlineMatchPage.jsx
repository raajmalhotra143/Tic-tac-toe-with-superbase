import React, { useEffect, useState, useRef, useCallback } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import Board from '../components/Board';
import Toast from '../components/Toast';
import { checkResult } from '../gameLogic';
import {
    createRoom, joinRoom, joinRoomByCode, findWaitingRoom,
    updateRoom, subscribeRoom, sendChat, subscribeChat,
    signOut
} from '../supabase';

export default function OnlineMatchPage({ user, playerEmoji, joinMode, roomCodeInput, onHome }) {
    const [room, setRoom] = useState(null);
    const [role, setRole] = useState(null); // 'host' | 'guest'
    const [board, setBoard] = useState(Array(9).fill(''));
    const [turn, setTurn] = useState('host');
    const [status, setStatus] = useState('matching'); // 'matching'|'waiting_for_guest'|'playing'|'done'
    const [result, setResult] = useState(null);
    const [opponentEmoji, setOpponentEmoji] = useState('❓');
    const [toast, setToast] = useState('');
    const [chats, setChats] = useState([]);
    const [chatInput, setChatInput] = useState('');
    const [codeCopied, setCodeCopied] = useState(false);

    const subRef = useRef(null);
    const chatSubRef = useRef(null);
    const roomRef = useRef(null);

    const showToast = (m) => { setToast(m); setTimeout(() => setToast(''), 3000); };

    const setupSubs = useCallback((r, myRole) => {
        subRef.current = subscribeRoom(r.id, (updated) => {
            setBoard(updated.board || Array(9).fill(''));
            setTurn(updated.turn);
            if (updated.status === 'playing') setStatus('playing');
            if (myRole === 'guest') setOpponentEmoji(updated.host_emoji || '❓');
            else setOpponentEmoji(updated.guest_emoji || '❓');
            if (updated.status === 'done') {
                setStatus('done');
                const winner = updated.winner;
                if (winner === myRole) setResult('win');
                else if (winner === 'draw') setResult('draw');
                else setResult('loss');
            }
        });
        chatSubRef.current = subscribeChat(r.id, (msg) => {
            setChats(prev => [...prev, msg]);
        });
    }, []);

    useEffect(() => {
        let mounted = true;
        async function init() {
            try {
                let r, myRole;

                if (joinMode === 'create') {
                    r = await createRoom(user.id, playerEmoji);
                    myRole = 'host';
                    // Wait for guest — status will flip to 'playing' via realtime
                    setStatus('waiting_for_guest');
                } else if (joinMode === 'code') {
                    r = await joinRoomByCode(roomCodeInput, user.id, playerEmoji);
                    myRole = 'guest';
                } else {
                    // quick match
                    const waiting = await findWaitingRoom(user.id);
                    if (waiting) {
                        r = await joinRoom(waiting.id, user.id, playerEmoji);
                        myRole = 'guest';
                    } else {
                        r = await createRoom(user.id, playerEmoji);
                        myRole = 'host';
                        setStatus('waiting_for_guest');
                    }
                }

                if (!mounted) return;
                setRoom(r);
                setRole(myRole);
                roomRef.current = r;
                setBoard(r.board || Array(9).fill(''));
                setTurn(r.turn || 'host');
                if (r.status === 'playing') { setStatus('playing'); }
                if (myRole === 'guest') setOpponentEmoji(r.host_emoji || '❓');
                setupSubs(r, myRole);
            } catch (err) {
                showToast('Error: ' + (err.message || 'Something went wrong'));
            }
        }
        init();
        return () => {
            mounted = false;
            subRef.current?.unsubscribe?.();
            chatSubRef.current?.unsubscribe?.();
        };
    }, []);

    const isMyTurn = role === turn && status === 'playing';

    const handleCellClick = async (i) => {
        if (!isMyTurn || board[i] !== '' || result) return;
        const copy = board.slice();
        const mySymbol = role === 'host' ? 'X' : 'O';
        copy[i] = mySymbol;
        const r = checkResult(copy);
        const newTurn = turn === 'host' ? 'guest' : 'host';
        let newStatus = 'playing';
        let winner = null;
        if (r) {
            newStatus = 'done';
            winner = r === 'draw' ? 'draw' : role;
        }
        try {
            await updateRoom(roomRef.current.id, {
                board: copy, turn: newTurn, status: newStatus,
                ...(winner ? { winner } : {}),
            });
        } catch (err) {
            showToast('Move failed: ' + (err.message || err));
        }
    };

    const handleSendChat = async () => {
        if (!chatInput.trim()) return;
        const name = user.email?.split('@')[0] || 'Player';
        await sendChat(roomRef.current?.id, user.id, name, chatInput.trim());
        setChatInput('');
    };

    const copyCode = () => {
        navigator.clipboard.writeText(room?.room_code || '');
        setCodeCopied(true);
        setTimeout(() => setCodeCopied(false), 2000);
    };

    const handleSignOut = async () => { await signOut(); onHome(); };

    // ---- Waiting for guest (host showing QR + code) ----
    if (status === 'waiting_for_guest' && room) {
        const roomUrl = `${window.location.origin}${window.location.pathname}#join:${room.room_code}`;

        const shareLink = async () => {
            if (navigator.share) {
                try {
                    await navigator.share({
                        title: 'Join my Tic-Tac-Toe game!',
                        text: `Use code ${room.room_code} or tap the link to join!`,
                        url: roomUrl,
                    });
                } catch (_) { }
            } else {
                await navigator.clipboard.writeText(roomUrl);
                showToast('🔗 Link copied to clipboard!');
            }
        };

        return (
            <div className="page">
                <button className="back-btn" onClick={onHome}>← Cancel</button>
                <h1 className="page-title">Room Created! 🏠</h1>
                <p className="page-subtitle">Share the code or QR — waiting for opponent…</p>
                <div className="section-gap" />

                {/* Main card */}
                <div style={{
                    background: 'var(--surface)', border: '2px solid var(--primary)',
                    borderRadius: 'var(--radius)', padding: '24px 28px', textAlign: 'center',
                    boxShadow: '0 0 40px var(--primary-glow)', zIndex: 1, maxWidth: 360, width: '100%'
                }}>
                    {/* Label */}
                    <p style={{ color: 'var(--muted)', fontSize: '0.75rem', textTransform: 'uppercase', letterSpacing: '.12em', marginBottom: 6 }}>
                        Room Code
                    </p>

                    {/* Big code */}
                    <div style={{
                        fontSize: '3.2rem', fontWeight: 900, fontFamily: 'Orbitron, sans-serif',
                        letterSpacing: '0.28em', color: 'var(--cyan)',
                        textShadow: '0 0 24px var(--cyan-glow)', marginBottom: 16,
                    }}>
                        {room.room_code}
                    </div>

                    {/* Action buttons */}
                    <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
                        <button
                            className={`btn ${codeCopied ? 'btn-cyan' : 'btn-ghost'} btn-sm`}
                            onClick={copyCode}
                            style={{ flex: 1 }}
                        >
                            {codeCopied ? '✅ Copied!' : '📋 Copy Code'}
                        </button>
                        <button
                            className="btn btn-primary btn-sm"
                            onClick={shareLink}
                            style={{ flex: 1 }}
                        >
                            🔗 Share Link
                        </button>
                    </div>

                    {/* Divider */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 16 }}>
                        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
                        <span style={{ color: 'var(--muted)', fontSize: '0.72rem', fontWeight: 600 }}>SCAN QR CODE</span>
                        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
                    </div>

                    {/* QR Code */}
                    <div style={{
                        background: '#fff', borderRadius: 16, padding: 14,
                        display: 'inline-flex', boxShadow: '0 4px 24px rgba(0,0,0,0.3)',
                    }}>
                        <QRCodeSVG
                            value={roomUrl}
                            size={192}
                            includeMargin={false}
                            level="M"
                        />
                    </div>

                    <p style={{ color: 'var(--muted)', fontSize: '0.72rem', marginTop: 12, lineHeight: 1.4 }}>
                        Friend scans this → lands straight in your game
                    </p>
                </div>

                <div style={{ height: 24 }} />
                <div className="matchmaking-anim" style={{ margin: '0 auto' }}>
                    <div className="matchmaking-anim-inner" />
                </div>
                <p className="matchmaking-status">Waiting for opponent to join…</p>
                <Toast message={toast} />
            </div>
        );
    }

    // ---- Auto matchmaking ----
    if (status === 'matching') {
        return (
            <div className="page">
                <button className="back-btn" onClick={onHome}>← Back</button>
                <h1 className="page-title">🌐 Finding Match…</h1>
                <div className="matchmaking-anim" style={{ margin: '32px auto' }}>
                    <div className="matchmaking-anim-inner" />
                </div>
                <p className="matchmaking-status">Searching for an opponent…</p>
                <Toast message={toast} />
            </div>
        );
    }

    // ---- Active game ----
    const myEmoji = playerEmoji;
    const oppEmoji = opponentEmoji;
    const mySymbol = role === 'host' ? 'X' : 'O';

    return (
        <div className="page">
            <button className="back-btn" onClick={onHome}>← Menu</button>

            <div className="game-wrapper">
                {/* Header */}
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%', zIndex: 1 }}>
                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                        <span style={{ fontSize: '0.75rem', color: 'var(--muted)', fontWeight: 600 }}>🌐 Online Match</span>
                        {room?.room_code && (
                            <span style={{ fontSize: '0.7rem', color: 'var(--cyan)', fontWeight: 700, letterSpacing: '.1em' }}>
                                #{room.room_code}
                            </span>
                        )}
                    </div>
                    <button className="btn btn-ghost btn-sm" onClick={handleSignOut}>Sign Out</button>
                </div>

                {/* Players */}
                <div className="game-header">
                    <div className={`player-badge ${isMyTurn && !result ? 'active' : ''}`}>
                        <span className="badge-emoji">{myEmoji}</span>
                        <span>You ({mySymbol})</span>
                    </div>
                    <span style={{ color: 'var(--muted)', fontWeight: 700 }}>VS</span>
                    <div className={`player-badge ${!isMyTurn && !result ? 'active' : ''}`}>
                        <span className="badge-emoji">{oppEmoji}</span>
                        <span>Opponent</span>
                    </div>
                </div>

                <div className={`status-bar ${result ? (result === 'win' ? 'win' : result === 'draw' ? 'draw' : 'loss') : ''}`}>
                    {result
                        ? result === 'win' ? '🏆 You Won!'
                            : result === 'draw' ? '🤝 Draw!'
                                : '💀 You Lost!'
                        : isMyTurn ? `Your turn ${myEmoji}` : `Opponent's turn ${oppEmoji}`}
                </div>

                <Board
                    board={board.map(v => v === '' ? null : v)}
                    onCellClick={handleCellClick}
                    playerEmoji={role === 'host' ? myEmoji : oppEmoji}
                    aiEmoji={role === 'host' ? oppEmoji : myEmoji}
                    disabled={!isMyTurn || !!result}
                />

                {result && (
                    <button className="btn btn-primary" onClick={onHome} style={{ zIndex: 1 }}>
                        🏠 Back to Menu
                    </button>
                )}

                {/* Chat */}
                <div className="chat-wrap">
                    <div className="chat-messages" ref={ref => { if (ref) ref.scrollTop = ref.scrollHeight; }}>
                        {chats.length === 0
                            ? <p style={{ color: 'var(--muted)', fontSize: '0.8rem' }}>No messages yet…</p>
                            : chats.map((m, i) => (
                                <div key={i} className="chat-msg">
                                    <span className="cm-name">{m.user_name}:</span>
                                    {m.message}
                                </div>
                            ))}
                    </div>
                    <div className="chat-input-row">
                        <input
                            value={chatInput}
                            onChange={e => setChatInput(e.target.value)}
                            onKeyDown={e => e.key === 'Enter' && handleSendChat()}
                            placeholder="Say something…"
                        />
                        <button onClick={handleSendChat}>Send</button>
                    </div>
                </div>
            </div>
            <Toast message={toast} />
        </div>
    );
}
