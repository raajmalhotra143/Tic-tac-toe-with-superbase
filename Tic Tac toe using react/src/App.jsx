import React, { useState, useEffect } from 'react';
import WelcomePage from './pages/WelcomePage';
import ModePage from './pages/ModePage';
import EmojiSelectPage from './pages/EmojiSelectPage';
import LevelSelectPage from './pages/LevelSelectPage';
import StageSelectPage from './pages/StageSelectPage';
import OfflineGamePage from './pages/OfflineGamePage';
import AuthPage from './pages/AuthPage';
import OnlineEmojiPage from './pages/OnlineEmojiPage';
import OnlineMatchPage from './pages/OnlineMatchPage';

// App-level routing state machine — no react-router needed
// Screens: welcome | mode | emojiSelect | levelSelect | stageSelect | offlineGame | auth | onlineEmoji | onlineMatch

export default function App() {
    const [screen, setScreen] = useState('welcome');
    const [playerEmoji, setPlayerEmoji] = useState('🦊');
    const [aiEmoji, setAiEmoji] = useState('🤖');
    const [difficulty, setDifficulty] = useState('easy');
    const [stageIndex, setStageIndex] = useState(0);
    const [user, setUser] = useState(null);
    const [onlineEmoji, setOnlineEmoji] = useState('🦁');
    const [joinMode, setJoinMode] = useState('quick');
    const [roomCodeInput, setRoomCodeInput] = useState('');

    const go = (s) => setScreen(s);

    // Detect QR link on load: #join:ROOMCODE → send to online mode
    useEffect(() => {
        const hash = window.location.hash;
        const match = hash.match(/[#]join[=:]([A-Z0-9]{6})/i);
        if (match) {
            // They arrived via a QR code link — skip to auth → onlineEmoji
            setRoomCodeInput(match[1].toUpperCase());
            setJoinMode('code');
            go('auth');
            window.history.replaceState(null, '', window.location.pathname);
        }
    }, []);

    /* ---- Welcome ---- */
    if (screen === 'welcome') {
        return <WelcomePage onPlay={() => go('mode')} />;
    }

    /* ---- Mode ---- */
    if (screen === 'mode') {
        return (
            <ModePage
                onBack={() => go('welcome')}
                onSelectMode={m => {
                    if (m === 'offline') go('emojiSelect');
                    else go('auth');
                }}
            />
        );
    }

    /* ---- Emoji Select (offline) ---- */
    if (screen === 'emojiSelect') {
        return (
            <EmojiSelectPage
                onBack={() => go('mode')}
                onConfirm={(pe, ae) => {
                    setPlayerEmoji(pe);
                    setAiEmoji(ae);
                    go('levelSelect');
                }}
            />
        );
    }

    /* ---- Level Select ---- */
    if (screen === 'levelSelect') {
        return (
            <LevelSelectPage
                onBack={() => go('emojiSelect')}
                onSelectLevel={lv => {
                    setDifficulty(lv);
                    go('stageSelect');
                }}
            />
        );
    }

    /* ---- Stage Select ---- */
    if (screen === 'stageSelect') {
        return (
            <StageSelectPage
                difficulty={difficulty}
                onBack={() => go('levelSelect')}
                onSelectStage={idx => {
                    setStageIndex(idx);
                    go('offlineGame');
                }}
            />
        );
    }

    /* ---- Offline Game ---- */
    if (screen === 'offlineGame') {
        return (
            <OfflineGamePage
                difficulty={difficulty}
                stageIndex={stageIndex}
                playerEmoji={playerEmoji}
                aiEmoji={aiEmoji}
                onHome={() => go('levelSelect')}
                onNextStage={(nextIdx) => {
                    if (nextIdx < 15) {
                        setStageIndex(nextIdx);
                        go('offlineGame');
                    } else {
                        go('stageSelect');
                    }
                }}
            />
        );
    }

    /* ---- Auth ---- */
    if (screen === 'auth') {
        return (
            <AuthPage
                onBack={() => go('mode')}
                onAuth={u => {
                    setUser(u);
                    go('onlineEmoji');
                }}
            />
        );
    }

    /* ---- Online Emoji ---- */
    if (screen === 'onlineEmoji') {
        return (
            <OnlineEmojiPage
                onBack={() => go('mode')}
                onConfirm={(em, mode, code) => {
                    setOnlineEmoji(em);
                    setJoinMode(mode);
                    setRoomCodeInput(code || '');
                    go('onlineMatch');
                }}
            />
        );
    }

    /* ---- Online Match ---- */
    if (screen === 'onlineMatch') {
        return (
            <OnlineMatchPage
                user={user}
                playerEmoji={onlineEmoji}
                joinMode={joinMode}
                roomCodeInput={roomCodeInput}
                onHome={() => go('mode')}
            />
        );
    }

    return null;
}
