import React from 'react';
import { getWinLine } from '../gameLogic';

export default function Board({ board, onCellClick, playerEmoji, aiEmoji, disabled }) {
    const winLine = getWinLine(board);

    return (
        <div className="board">
            {board.map((val, i) => {
                const isWinner = winLine.includes(i);
                const isPlayer = val === 'X';
                const taken = !!val;
                return (
                    <div
                        key={i}
                        className={`cell ${taken ? 'taken' : ''} ${taken && isPlayer ? 'x' : taken ? 'o' : ''} ${isWinner ? 'winner' : ''}`}
                        onClick={() => !disabled && !taken && onCellClick(i)}
                        role="button"
                        tabIndex={disabled || taken ? -1 : 0}
                        onKeyDown={e => e.key === 'Enter' && !disabled && !taken && onCellClick(i)}
                        aria-label={`Cell ${i + 1}${val ? ` occupied by ${val}` : ''}`}
                    >
                        {val && (
                            <span className="cell-mark">
                                {isPlayer ? playerEmoji : aiEmoji}
                            </span>
                        )}
                    </div>
                );
            })}
        </div>
    );
}
