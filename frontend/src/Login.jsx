import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "./firebase";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Login() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const login = async (e) => {
        e.preventDefault();
        setLoading(true);

        try {
            const userCredential = await signInWithEmailAndPassword(auth, email, password);
            const user = userCredential.user;
            console.log(user);

            const token = await user.getIdToken();

            if (user.uid === import.meta.env.VITE_ADMIN_USER_ID) {
                console.log("ADMIN!");
                localStorage.setItem("token", token);
                navigate("/");
                window.location.reload();
            } else {
                // Optional: handle non-admin login differently if needed
                alert("Access restricted to admin only.");
            }
        } catch (err) {
            alert(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
            <div className="w-full max-w-md">
                {/* Card */}
                <div className="bg-white rounded-2xl shadow-xl border border-slate-200 overflow-hidden">
                    {/* Header */}
                    <div className="bg-indigo-600 px-8 py-10 text-center">
                        <h1 className="text-3xl font-bold text-white tracking-tight">
                            Admin Login
                        </h1>
                        <p className="mt-3 text-indigo-100 text-sm">
                            Sign in to access the dashboard
                        </p>
                    </div>

                    {/* Form */}
                    <form onSubmit={login} className="p-8 space-y-6">
                        {/* Email */}
                        <div>
                            <label
                                htmlFor="email"
                                className="block text-sm font-medium text-slate-700 mb-1.5"
                            >
                                Email address
                            </label>
                            <input
                                id="email"
                                type="email"
                                placeholder="admin@example.com"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                required
                                className={`
                  w-full px-4 py-3 rounded-xl border border-slate-300 
                  focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500
                  bg-slate-50 text-slate-900 placeholder-slate-400
                  transition-all duration-200
                `}
                            />
                        </div>

                        {/* Password */}
                        <div>
                            <label
                                htmlFor="password"
                                className="block text-sm font-medium text-slate-700 mb-1.5"
                            >
                                Password
                            </label>
                            <input
                                id="password"
                                type="password"
                                placeholder="••••••••"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                                className={`
                  w-full px-4 py-3 rounded-xl border border-slate-300 
                  focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500
                  bg-slate-50 text-slate-900 placeholder-slate-400
                  transition-all duration-200
                `}
                            />
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={loading}
                            className={`
                w-full flex items-center justify-center gap-2 
                px-6 py-3.5 rounded-xl font-semibold text-white
                bg-indigo-600 hover:bg-indigo-700 
                focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2
                shadow-lg shadow-indigo-200
                transition-all duration-200
                disabled:opacity-60 disabled:cursor-not-allowed
              `}
                        >
                            {loading ? (
                                <>
                                    <svg
                                        className="animate-spin h-5 w-5 text-white"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                    >
                                        <circle
                                            className="opacity-25"
                                            cx="12"
                                            cy="12"
                                            r="10"
                                            stroke="currentColor"
                                            strokeWidth="4"
                                        />
                                        <path
                                            className="opacity-75"
                                            fill="currentColor"
                                            d="M4 12a8 8 0 018-8v8h8a8 8 0 01-16 0z"
                                        />
                                    </svg>
                                    Signing in...
                                </>
                            ) : (
                                "Sign In"
                            )}
                        </button>
                    </form>

                    {/* Optional footer */}
                    <div className="px-8 py-5 bg-slate-50 border-t border-slate-100 text-center text-sm text-slate-500">
                        Restricted access • Admin only
                    </div>
                </div>
            </div>
        </div>
    );
}