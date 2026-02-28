import React, { useState } from 'react';
import EmojiPicker from '../components/EmojiPicker';

const AI_EMOJI = '🤖';

export default function EmojiSelectPage({ onConfirm, onBack }) {
    const [selected, setSelected] = useState('🦊');

    return (
        <div className="page">
            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">Choose Your Emoji</h1>
            <p className="page-subtitle">Your emoji vs AI: <strong>{AI_EMOJI}</strong></p>
            <div className="section-gap" />
            <EmojiPicker selected={selected} onSelect={setSelected} />
            <div style={{ height: '32px' }} />
            <button
                className="btn btn-primary btn-lg"
                onClick={() => onConfirm(selected, AI_EMOJI)}
            >
                Confirm &amp; Play
            </button>
        </div>
    );
}
