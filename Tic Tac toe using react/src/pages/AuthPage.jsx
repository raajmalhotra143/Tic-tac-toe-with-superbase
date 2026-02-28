import React, { useState } from 'react';
import { signIn, signUp } from '../supabase';
import Toast from '../components/Toast';

export default function AuthPage({ onAuth, onBack }) {
    const [mode, setMode] = useState('login'); // 'login' | 'register'
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [toast, setToast] = useState('');

    const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(''), 2800); };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!email || !password) { showToast('Please fill all fields'); return; }
        setLoading(true);
        try {
            if (mode === 'login') {
                const { user } = await signIn(email, password);
                onAuth(user);
            } else {
                const { user } = await signUp(email, password);
                showToast('Account created! Check your email to confirm.');
                if (user) onAuth(user);
            }
        } catch (err) {
            showToast(err.message || 'Something went wrong');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="page">
            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">🔐 {mode === 'login' ? 'Sign In' : 'Create Account'}</h1>
            <p className="page-subtitle">Online multiplayer requires an account</p>
            <div className="section-gap" />
            <form className="auth-form card card-glow" onSubmit={handleSubmit}>
                <div className="form-group">
                    <label className="input-label">Email</label>
                    <input
                        className="input"
                        type="email"
                        placeholder="you@email.com"
                        value={email}
                        onChange={e => setEmail(e.target.value)}
                        autoComplete="email"
                        required
                    />
                </div>
                <div className="form-group">
                    <label className="input-label">Password</label>
                    <input
                        className="input"
                        type="password"
                        placeholder="••••••••"
                        value={password}
                        onChange={e => setPassword(e.target.value)}
                        autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
                        required
                    />
                </div>
                <button className="btn btn-primary btn-block" type="submit" disabled={loading}>
                    {loading ? '⏳ Please wait…' : mode === 'login' ? '→ Sign In' : '→ Create Account'}
                </button>
                <button
                    type="button"
                    className="btn btn-ghost btn-block btn-sm"
                    onClick={() => setMode(mode === 'login' ? 'register' : 'login')}
                >
                    {mode === 'login' ? "Don't have an account? Sign Up" : 'Already have an account? Login'}
                </button>
            </form>
            <Toast message={toast} />
        </div>
    );
}
