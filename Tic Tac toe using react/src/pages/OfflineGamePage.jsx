import React, { useState, useEffect, useCallback } from 'react';
import Board from '../components/Board';
import ResultOverlay from '../components/ResultOverlay';
import { checkResult, getAIMove, calcStars, isForceImpossibleStage } from '../gameLogic';
import { completeStage, recordScore } from '../progress';

export default function OfflineGamePage({ difficulty, stageIndex, playerEmoji, aiEmoji, onNextStage, onHome }) {
    const [board, setBoard] = useState(Array(9).fill(null));
    const [playerTurn, setPlayerTurn] = useState(true); // player is always X
    const [result, setResult] = useState(null); // null | 'win' | 'draw' | 'loss'
    const [moves, setMoves] = useState(0);
    const [stars, setStars] = useState(0);
    const [thinking, setThinking] = useState(false);

    const stage = stageIndex + 1; // 1-based
    const isLast = stageIndex === 14;
    const forceImpossible = isForceImpossibleStage(stage, difficulty);

    const handleResult = useCallback((r, currentBoard, moveCount) => {
        const mapped = r === 'X' ? 'win' : r === 'O' ? 'loss' : 'draw';
        // force impossible stage 15 — never a win
        const final = forceImpossible && mapped === 'win' ? 'draw' : mapped;
        const s = final === 'win' ? calcStars(moveCount) : 0;
        setStars(s);
        setResult(final);
        completeStage(difficulty, stageIndex, s);
        recordScore(final);
    }, [difficulty, stageIndex, forceImpossible]);

    // AI move effect
    useEffect(() => {
        if (playerTurn || result) return;
        setThinking(true);
        const delay = 400 + Math.random() * 300;
        const t = setTimeout(() => {
            setBoard(prev => {
                const copy = prev.slice();
                const idx = getAIMove(copy, difficulty, stage);
                if (idx === null) return prev;
                copy[idx] = 'O';
                const r = checkResult(copy);
                const newMoves = moves + 1;
                setMoves(newMoves);
                if (r) handleResult(r, copy, newMoves);
                else setPlayerTurn(true);
                return copy;
            });
            setThinking(false);
        }, delay);
        return () => clearTimeout(t);
    }, [playerTurn, result, difficulty, stage, moves, handleResult]);

    const handleCellClick = (i) => {
        if (!playerTurn || result || board[i] || thinking) return;
        const copy = board.slice();
        copy[i] = 'X';
        const newMoves = moves + 1;
        setMoves(newMoves);
        setBoard(copy);
        const r = checkResult(copy);
        if (r) handleResult(r, copy, newMoves);
        else setPlayerTurn(false);
    };

    const replay = () => {
        setBoard(Array(9).fill(null));
        setPlayerTurn(true);
        setResult(null);
        setMoves(0);
        setStars(0);
    };

    const statusText = thinking ? '🤔 AI is thinking…'
        : playerTurn ? `Your turn ${playerEmoji}` : `Opponent's turn ${aiEmoji}`;

    const diffLabel = { easy: '🌱', normal: '⚔️', impossible: '💀' }[difficulty];

    return (
        <div className="page">
            <button className="back-btn" onClick={onHome}>← Menu</button>

            <div className="game-wrapper">
                {/* Stage info */}
                <div style={{ textAlign: 'center', zIndex: 1 }}>
                    <span style={{
                        background: 'var(--surface2)', border: '1px solid var(--border)',
                        borderRadius: '50px', padding: '6px 18px', fontSize: '0.85rem', fontWeight: 700,
                    }}>
                        {diffLabel} Stage {stage} / 15
                    </span>
                </div>

                {/* Player badges */}
                <div className="game-header">
                    <div className={`player-badge ${playerTurn && !result ? 'active' : ''}`}>
                        <span className="badge-emoji">{playerEmoji}</span>
                        <span>You</span>
                    </div>
                    <span style={{ color: 'var(--muted)', fontWeight: 700 }}>VS</span>
                    <div className={`player-badge ${!playerTurn && !result ? 'active' : ''}`}>
                        <span className="badge-emoji">{aiEmoji}</span>
                        <span>AI</span>
                    </div>
                </div>

                <div className={`status-bar`}>{statusText}</div>

                <Board
                    board={board}
                    onCellClick={handleCellClick}
                    playerEmoji={playerEmoji}
                    aiEmoji={aiEmoji}
                    disabled={!playerTurn || !!result || thinking}
                />
            </div>

            {result && (
                <ResultOverlay
                    result={result}
                    stars={stars}
                    moves={moves}
                    playerEmoji={playerEmoji}
                    aiEmoji={aiEmoji}
                    isLastStage={isLast}
                    onNextStage={() => onNextStage(stageIndex + 1)}
                    onReplay={replay}
                    onHome={onHome}
                />
            )}
        </div>
    );
}
