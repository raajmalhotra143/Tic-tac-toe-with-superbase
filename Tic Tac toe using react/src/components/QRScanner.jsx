import React, { useEffect, useRef, useState } from 'react';
import { Html5Qrcode } from 'html5-qrcode';

/**
 * QRScanner – opens device camera and decodes a QR code.
 * Props:
 *   onScan(text)  – called with the decoded string
 *   onError(msg)  – called on unrecoverable error
 *   onClose()     – user pressed Cancel
 */
export default function QRScanner({ onScan, onError, onClose }) {
    const [starting, setStarting] = useState(true);
    const [scanMsg, setScanMsg] = useState('Point your camera at the QR code');
    const scannerRef = useRef(null);
    const domId = 'qr-scanner-region';

    useEffect(() => {
        let scanner;
        async function start() {
            try {
                scanner = new Html5Qrcode(domId);
                scannerRef.current = scanner;

                await scanner.start(
                    { facingMode: 'environment' }, // rear camera
                    {
                        fps: 10,
                        qrbox: { width: 230, height: 230 },
                        aspectRatio: 1.0,
                    },
                    (decodedText) => {
                        // Extract room code from URL hash or plain code
                        let code = decodedText;
                        // Handle URL like http://localhost:3000/#join:XY2K9R
                        const match = decodedText.match(/[#?]join[=:]([\w]{6})/i)
                            || decodedText.match(/([A-Z0-9]{6})$/i);
                        if (match) code = match[1].toUpperCase();
                        stop().then(() => onScan(code));
                    },
                    () => { } // ignore per-frame errors
                );
                setStarting(false);
                setScanMsg('Point your camera at the QR code');
            } catch (err) {
                const msg = err?.message || String(err);
                if (msg.toLowerCase().includes('permission') || msg.toLowerCase().includes('denied')) {
                    setScanMsg('Camera permission denied. Please allow camera access.');
                } else {
                    setScanMsg('Camera error: ' + msg);
                }
                if (onError) onError(msg);
                setStarting(false);
            }
        }

        async function stop() {
            try {
                if (scannerRef.current?.isScanning) {
                    await scannerRef.current.stop();
                }
            } catch (_) { }
        }

        start();
        return () => { stop(); };
    }, []);

    return (
        <div style={{
            position: 'fixed', inset: 0, zIndex: 999,
            background: 'rgba(10,10,26,0.96)',
            display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
            padding: '24px',
        }}>
            <h2 style={{
                fontFamily: 'Orbitron, sans-serif', fontSize: '1.4rem',
                fontWeight: 900, marginBottom: '8px',
                background: 'linear-gradient(135deg,var(--primary),var(--cyan))',
                WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            }}>
                📷 Scan QR Code
            </h2>
            <p style={{ color: 'var(--muted)', fontSize: '0.85rem', marginBottom: '20px', textAlign: 'center' }}>
                {scanMsg}
            </p>

            {/* Camera preview container */}
            <div style={{
                width: '280px', height: '280px',
                borderRadius: '20px', overflow: 'hidden',
                border: '2px solid var(--primary)',
                boxShadow: '0 0 32px var(--primary-glow)',
                position: 'relative', background: '#000',
            }}>
                {starting && (
                    <div style={{
                        position: 'absolute', inset: 0,
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        color: 'var(--muted)', fontSize: '0.85rem',
                    }}>
                        Starting camera…
                    </div>
                )}
                {/* html5-qrcode renders into this div */}
                <div id={domId} style={{ width: '100%', height: '100%' }} />

                {/* Corner markers overlay */}
                {!starting && (
                    <>
                        {['top-left', 'top-right', 'bottom-left', 'bottom-right'].map(pos => (
                            <div key={pos} style={{
                                position: 'absolute',
                                width: 28, height: 28,
                                borderColor: 'var(--cyan)',
                                borderStyle: 'solid',
                                borderWidth: 0,
                                ...(pos === 'top-left' ? { top: 20, left: 20, borderTopWidth: 3, borderLeftWidth: 3, borderRadius: '4px 0 0 0' } : {}),
                                ...(pos === 'top-right' ? { top: 20, right: 20, borderTopWidth: 3, borderRightWidth: 3, borderRadius: '0 4px 0 0' } : {}),
                                ...(pos === 'bottom-left' ? { bottom: 20, left: 20, borderBottomWidth: 3, borderLeftWidth: 3, borderRadius: '0 0 0 4px' } : {}),
                                ...(pos === 'bottom-right' ? { bottom: 20, right: 20, borderBottomWidth: 3, borderRightWidth: 3, borderRadius: '0 0 4px 0' } : {}),
                            }} />
                        ))}
                    </>
                )}
            </div>

            <div style={{ height: 24 }} />
            <button
                className="btn btn-ghost"
                onClick={onClose}
                style={{ minWidth: 160 }}
            >
                ✕ Cancel
            </button>
        </div>
    );
}
