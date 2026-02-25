import React, { useState, useEffect } from 'react';
import EmojiPicker from '../components/EmojiPicker';
import QRScanner from '../components/QRScanner';
import Toast from '../components/Toast';

export default function OnlineEmojiPage({ onConfirm, onBack }) {
    const [selected, setSelected] = useState('🦁');
    const [tab, setTab] = useState('pick'); // 'pick' | 'join'
    const [roomCode, setRoomCode] = useState('');
    const [showScanner, setShowScanner] = useState(false);
    const [toast, setToast] = useState('');
    const [error, setError] = useState('');

    const showToast = (m) => { setToast(m); setTimeout(() => setToast(''), 3000); };

    // Auto-fill code from URL hash (#join:ROOMCODE)
    useEffect(() => {
        const hash = window.location.hash;
        const match = hash.match(/[#]join[=:]([A-Z0-9]{6})/i);
        if (match) {
            const code = match[1].toUpperCase();
            setRoomCode(code);
            setTab('join');
            showToast(`Room code ${code} auto-filled from QR link!`);
            // Clean the hash so refresh doesn't re-trigger
            window.history.replaceState(null, '', window.location.pathname);
        }
    }, []);

    const go = (mode, code = '') => {
        if (!selected) { setError('Pick an emoji first!'); return; }
        setError('');
        onConfirm(selected, mode, code);
    };

    const handleCodeJoin = () => {
        if (roomCode.length !== 6) { setError('Enter a valid 6-character code'); return; }
        go('code', roomCode);
    };

    const handleScanSuccess = (code) => {
        setShowScanner(false);
        if (!code || code.length < 4) {
            showToast('Could not read a valid room code from QR');
            return;
        }
        const clean = code.slice(0, 6).toUpperCase();
        setRoomCode(clean);
        setTab('join');
        showToast(`📷 Scanned! Code: ${clean}`);
    };

    const handleScanError = (msg) => {
        setShowScanner(false);
        showToast('Scanner error: ' + msg);
    };

    return (
        <div className="page">
            {showScanner && (
                <QRScanner
                    onScan={handleScanSuccess}
                    onError={handleScanError}
                    onClose={() => setShowScanner(false)}
                />
            )}

            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">🌐 Online Mode</h1>
            <p className="page-subtitle">Choose your emoji, then join or create a game</p>

            <div className="section-gap" />
            <EmojiPicker selected={selected} onSelect={setSelected} />
            <div style={{ height: '28px' }} />

            {/* Tabs */}
            <div style={{
                display: 'flex', gap: 8, background: 'var(--surface2)',
                border: '1px solid var(--border)', borderRadius: 50,
                padding: 4, marginBottom: 20, zIndex: 1,
            }}>
                {[
                    { key: 'pick', label: '🎮 Create / Quick' },
                    { key: 'join', label: '🔑 Join Room' },
                ].map(t => (
                    <button
                        key={t.key}
                        onClick={() => { setTab(t.key); setError(''); }}
                        style={{
                            background: tab === t.key ? 'var(--primary)' : 'transparent',
                            color: tab === t.key ? '#fff' : 'var(--muted)',
                            border: 'none', borderRadius: 50, padding: '8px 18px',
                            fontWeight: 700, fontSize: '0.82rem', cursor: 'pointer',
                            transition: 'all 0.2s ease',
                        }}
                    >
                        {t.label}
                    </button>
                ))}
            </div>

            {/* --- Create / Quick tab --- */}
            {tab === 'pick' && (
                <div style={{
                    display: 'flex', flexDirection: 'column', gap: 12,
                    width: '100%', maxWidth: 320, zIndex: 1,
                }}>
                    <button className="btn btn-primary btn-block" onClick={() => go('create')}>
                        🏠 Create Room &amp; Get Code
                    </button>
                    <button className="btn btn-ghost btn-block" onClick={() => go('quick')}>
                        ⚡ Quick Match (Auto)
                    </button>
                    {error && <p style={{ color: 'var(--pink)', fontSize: '0.85rem', textAlign: 'center' }}>{error}</p>}
                </div>
            )}

            {/* --- Join tab --- */}
            {tab === 'join' && (
                <div style={{
                    display: 'flex', flexDirection: 'column', gap: 12,
                    width: '100%', maxWidth: 320, zIndex: 1,
                }}>

                    {/* Scan QR button */}
                    <button
                        className="btn btn-cyan btn-block"
                        onClick={() => setShowScanner(true)}
                        style={{ fontSize: '1rem', gap: 10 }}
                    >
                        <span>📷 Scan QR Code</span>
                    </button>

                    <div style={{
                        display: 'flex', alignItems: 'center', gap: 12,
                    }}>
                        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
                        <span style={{ color: 'var(--muted)', fontSize: '0.78rem', fontWeight: 600 }}>OR</span>
                        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
                    </div>

                    {/* Manual code entry */}
                    <div style={{ textAlign: 'center' }}>
                        <p style={{ color: 'var(--muted)', fontSize: '0.82rem', marginBottom: 10 }}>
                            Enter the 6-character room code
                        </p>
                        <input
                            className="input"
                            placeholder="e.g. XY2K9R"
                            value={roomCode}
                            onChange={e => {
                                setRoomCode(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6));
                                setError('');
                            }}
                            style={{
                                textAlign: 'center', fontSize: '1.6rem',
                                fontWeight: 900, letterSpacing: '0.3em',
                                fontFamily: 'Orbitron, sans-serif',
                            }}
                            maxLength={6}
                            autoFocus={tab === 'join'}
                            onKeyDown={e => e.key === 'Enter' && handleCodeJoin()}
                        />

                        {/* Code character indicators */}
                        <div style={{ display: 'flex', gap: 6, justifyContent: 'center', marginTop: 8 }}>
                            {Array.from({ length: 6 }).map((_, i) => (
                                <div key={i} style={{
                                    width: 10, height: 4, borderRadius: 2,
                                    background: roomCode[i] ? 'var(--cyan)' : 'var(--border)',
                                    transition: 'background 0.2s ease',
                                }} />
                            ))}
                        </div>
                    </div>

                    {error && (
                        <p style={{
                            color: 'var(--pink)', fontSize: '0.85rem',
                            textAlign: 'center', animation: 'shake 0.3s ease',
                        }}>
                            {error}
                        </p>
                    )}

                    <button
                        className="btn btn-primary btn-block"
                        disabled={roomCode.length !== 6}
                        onClick={handleCodeJoin}
                        style={{ opacity: roomCode.length === 6 ? 1 : 0.5 }}
                    >
                        → Join Game
                    </button>
                </div>
            )}

            <Toast message={toast} />
        </div>
    );
}
