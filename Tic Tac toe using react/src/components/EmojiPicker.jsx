import React from 'react';

const EMOJIS = ['🦊', '🐼', '🦁', '🐸', '🐯', '🐺', '🦄', '🐲', '👾', '🤖', '🦅', '🐙', '👻', '💀', '🎃', '⚡', '🔥', '❄️', '🌊', '💎'];

export default function EmojiPicker({ selected, onSelect }) {
    return (
        <div className="emoji-grid">
            {EMOJIS.map(e => (
                <div
                    key={e}
                    className={`emoji-option ${selected === e ? 'selected' : ''}`}
                    onClick={() => onSelect(e)}
                    role="button"
                    tabIndex={0}
                    onKeyDown={ev => ev.key === 'Enter' && onSelect(e)}
                    aria-label={`Select emoji ${e}`}
                >
                    {e}
                </div>
            ))}
        </div>
    );
}
