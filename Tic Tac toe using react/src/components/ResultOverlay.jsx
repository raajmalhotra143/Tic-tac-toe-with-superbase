import React from 'react';
import StarRating from './StarRating';

export default function ResultOverlay({ result, stars, playerEmoji, aiEmoji, moves, onNextStage, onReplay, onHome, isLastStage }) {
    const isWin = result === 'win';
    const isDraw = result === 'draw';

    return (
        <div className="result-overlay">
            <div className="result-card">
                <span className="result-emoji">
                    {isWin ? '🏆' : isDraw ? '🤝' : '💀'}
                </span>
                <h2 className={`result-title ${isWin ? 'gradient-text' : ''}`}>
                    {isWin ? 'You Won!' : isDraw ? "It's a Draw!" : 'You Lost!'}
                </h2>
                <p className="result-moves">
                    {isWin ? `Finished in ${moves} move${moves !== 1 ? 's' : ''}` : isDraw ? 'No winner this time' : 'Better luck next stage!'}
                </p>
                {isWin && <StarRating stars={stars} />}
                <div className="result-actions">
                    {isWin && !isLastStage && (
                        <button className="btn btn-primary" onClick={onNextStage}>
                            Next Stage →
                        </button>
                    )}
                    <button className="btn btn-ghost" onClick={onReplay}>
                        ↩ Replay
                    </button>
                    <button className="btn btn-ghost btn-sm" onClick={onHome}>
                        🏠 Menu
                    </button>
                </div>
            </div>
        </div>
    );
}
