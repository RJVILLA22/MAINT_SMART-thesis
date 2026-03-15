import React, { useState, useEffect } from 'react';
import { Search, ChevronRight, User, Clock, Package, Users, Menu, X, Loader2, LogOut } from 'lucide-react';
import SidebarComp from './Sidebar';
import UsersComp from './Users';
import History from './History';
import { useNavigate } from "react-router-dom";


const API_BASE_URL = `${import.meta.env.VITE_BASE_URL}/inventory`; // Update with your actual API URL

const Inventory = () => {
    const [activeModule, setActiveModule] = useState('inventory');
    const [activeSubmodule, setActiveSubmodule] = useState('borrowed');
    const [sidebarOpen, setSidebarOpen] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');

    // Data states
    const [borrowedTools, setBorrowedTools] = useState([]);
    const [availableTools, setAvailableTools] = useState([]);
    const [allTools, setAllTools] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const navigate = useNavigate();

    const modules = [
        {
            id: 'inventory',
            name: 'Inventory',
            icon: Package,
            submodules: [
                { id: 'borrowed', name: 'Borrowed Tools' },
                { id: 'available', name: 'Available Tools' },
                { id: 'all', name: 'All Tools' }
            ]
        },
        {
            id: 'users',
            name: 'Users',
            icon: Users,
            submodules: []
        },
        {
            id: 'history',
            name: 'History',
            icon: History,
            submodules: []
        }
    ];

    const currentModule = modules.find(m => m.id === activeModule);

    // Fetch borrowed tools
    const fetchBorrowedTools = async () => {
        try {
            setLoading(true);
            setError(null);
            console.log(API_BASE_URL);
            const response = await fetch(`${API_BASE_URL}/borrowed`);

            console.log(response)
            if (!response.ok) throw new Error('Failed to fetch borrowed tools');
            const data = await response.json();
            setBorrowedTools(data);
        } catch (err) {
            setError(err.message);
            console.error('Error fetching borrowed tools:', err);
        } finally {
            setLoading(false);
        }
    };

    // Fetch available tools
    const fetchAvailableTools = async () => {
        try {
            setLoading(true);
            setError(null);
            const response = await fetch(`${API_BASE_URL}/tools/available`);
            if (!response.ok) throw new Error('Failed to fetch available tools');
            const data = await response.json();
            setAvailableTools(data);
        } catch (err) {
            setError(err.message);
            console.error('Error fetching available tools:', err);
        } finally {
            setLoading(false);
        }
    };

    // Fetch all tools
    const fetchAllTools = async () => {
        try {
            setLoading(true);
            setError(null);
            const response = await fetch(`${API_BASE_URL}/tools`);
            if (!response.ok) throw new Error('Failed to fetch all tools');
            const data = await response.json();
            setAllTools(data);
        } catch (err) {
            setError(err.message);
            console.error('Error fetching all tools:', err);
        } finally {
            setLoading(false);
        }
    };

    // Fetch data when submodule changes
    useEffect(() => {
        if (activeModule === 'inventory') {
            if (activeSubmodule === 'borrowed') {
                fetchBorrowedTools();
            } else if (activeSubmodule === 'available') {
                fetchAvailableTools();
            } else if (activeSubmodule === 'all') {
                fetchAllTools();
            }
        }
    }, [activeModule, activeSubmodule]);

    // Format date helper
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    };

    // Filter tools based on search query
    const filterTools = (tools, type) => {
        if (!searchQuery) return tools;

        return tools.filter(tool => {
            const searchLower = searchQuery.toLowerCase();
            const modelMatch = tool.model?.toLowerCase().includes(searchLower);
            const idMatch = tool.id?.toLowerCase().includes(searchLower);
            const descMatch = tool.description?.toLowerCase().includes(searchLower);

            if (type === 'borrowed') {
                const borrowerMatch = tool.borrowedBy?.toLowerCase().includes(searchLower);
                return modelMatch || idMatch || descMatch || borrowerMatch;
            }

            return modelMatch || idMatch || descMatch;
        });
    };

    const renderToolCard = (tool, type) => {
        if (type === 'borrowed') {
            const isOverdue = tool.dueDate && new Date(tool.dueDate) < new Date();

            return (
                <div
                    key={tool.id}
                    className="bg-white border border-slate-200 rounded-xl p-6 hover:border-indigo-300 hover:shadow-md transition-all duration-300"
                >
                    <div className="flex items-start justify-between mb-3">
                        <h3 className="text-2xl font-bold text-slate-900 tracking-tight">{tool.model}</h3>
                        <div className="flex items-center gap-2">
                            <div className="relative group">
                                <div className="w-3 h-3 rounded-full bg-yellow-400 animate-pulse"></div>
                                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 bg-gray-800 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                                    Borrowed
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="space-y-1.5">
                        <p className="text-sm text-slate-600">
                            Borrowed by: <span className="text-indigo-600 font-semibold underline decoration-indigo-200 decoration-2 underline-offset-2">{tool.borrowedBy}</span>
                        </p>
                        <p className="text-sm text-slate-600">
                            Borrowed: {formatDate(tool.borrowedAt)}
                        </p>
                        <p className={`text-sm font-medium ${isOverdue ? 'text-red-600' : 'text-slate-600'}`}>
                            Due: {formatDate(tool.dueDate)} {isOverdue && '(Overdue!)'}
                        </p>
                    </div>
                </div>
            );
        } else if (type === 'available') {
            return (
                <div
                    key={tool.id}
                    className="bg-white border border-slate-200 rounded-xl p-6 hover:border-emerald-300 hover:shadow-md transition-all duration-300"
                >
                    <div className="flex items-start justify-between mb-3">
                        <h3 className="text-2xl font-bold text-slate-900 tracking-tight">{tool.model}</h3>
                        <div className="relative group">
                            <div className="w-3 h-3 rounded-full bg-green-400"></div>
                            <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 bg-gray-800 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                                Available
                            </div>
                        </div>
                    </div>
                    <div className="space-y-1.5">
                        <p className="text-sm text-slate-700">
                            <span className="font-semibold">Allowable borrowing days:</span> {tool.borrowDays} days
                        </p>
                        {tool.description && (
                            <p className="text-sm text-slate-600">{tool.description}</p>
                        )}
                    </div>
                </div>
            );
        } else {
            // For "all tools" view
            const isBorrowed = tool.status === 'borrowed';

            return (
                <div
                    key={tool.id}
                    className="bg-white border border-slate-200 rounded-xl p-6 hover:border-indigo-300 hover:shadow-md transition-all duration-300"
                >
                    <div className="flex items-start justify-between mb-3">
                        <h3 className="text-2xl font-bold text-slate-900 tracking-tight">{tool.model}</h3>
                        <div className="relative group">
                            <div className={`w-3 h-3 rounded-full ${isBorrowed ? 'bg-yellow-400 animate-pulse' : 'bg-green-400'}`}></div>
                            <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 bg-gray-800 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                                {isBorrowed ? 'Borrowed' : 'Available'}
                            </div>
                        </div>
                    </div>
                    <div className="space-y-1.5">
                        <p className="text-sm text-slate-700">
                            <span className="font-semibold">Status:</span>{' '}
                            <span className={`${isBorrowed ? 'text-yellow-600' : 'text-green-600'} font-medium`}>
                                {tool.status.charAt(0).toUpperCase() + tool.status.slice(1)}
                            </span>
                        </p>
                        <p className="text-sm text-slate-700">
                            <span className="font-semibold">Allowable borrowing days:</span> {tool.borrowDays} days
                        </p>
                        {tool.description && (
                            <p className="text-sm text-slate-600">{tool.description}</p>
                        )}
                    </div>
                </div>
            );
        }
    };

    // Get filtered tools based on active submodule
    const getDisplayTools = () => {
        if (activeSubmodule === 'borrowed') {
            return filterTools(borrowedTools, 'borrowed');
        } else if (activeSubmodule === 'available') {
            return filterTools(availableTools, 'available');
        } else {
            return filterTools(allTools, 'all');
        }
    };

    const displayTools = getDisplayTools();

    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 font-['Segoe_UI',_'Arial',_sans-serif]">
            {/* Header */}
            <header className="bg-white border-b border-slate-200 sticky top-0 z-50 shadow-sm">
                <div className="px-6 py-4 flex items-center justify-between">
                    <div className="flex items-center gap-4">
                        <button
                            onClick={() => setSidebarOpen(!sidebarOpen)}
                            className="p-2 hover:bg-slate-100 rounded-lg transition-colors lg:hidden"
                        >
                            {sidebarOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
                        </button>
                        <div>
                            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">MAINT - SMART</h1>
                            <p className="text-sm text-slate-600 mt-0.5">Philippine State College of Aeronautics</p>
                        </div>
                    </div>
                    <button
                        onClick={() => {
                            localStorage.removeItem("token");
                            navigate("/login", { replace: true });
                            window.location.reload();
                        }}
                        className="p-2 hover:bg-slate-100 rounded-full transition-colors"
                    >
                        <LogOut className="w-6 h-6 text-slate-700" />
                    </button>
                </div>
            </header>

            <div className="flex">
                {/* Sidebar */}
                <SidebarComp
                    sidebarOpen={sidebarOpen}
                    activeModule={activeModule}
                    setActiveModule={setActiveModule}
                    activeSubmodule={activeSubmodule}
                    setActiveSubmodule={setActiveSubmodule}
                />

                {/* Main Content */}
                <main className="flex-1 p-8 max-w-7xl mx-auto w-full">
                    {activeModule === 'inventory' && (
                        <>
                            {/* Tab Navigation */}
                            <div className="flex gap-3 mb-8">
                                {currentModule.submodules.map((sub) => (
                                    <button
                                        key={sub.id}
                                        onClick={() => setActiveSubmodule(sub.id)}
                                        className={`
                                            px-6 py-3 rounded-xl font-semibold transition-all duration-200
                                            ${activeSubmodule === sub.id
                                                ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-200'
                                                : 'bg-white text-slate-700 hover:bg-slate-50 border border-slate-200'
                                            }
                                        `}
                                    >
                                        {sub.name}
                                    </button>
                                ))}
                            </div>

                            {/* Info Banner */}
                            <div className="bg-indigo-50 border border-indigo-200 rounded-2xl p-6 mb-8">
                                <p className="text-indigo-900 font-medium">
                                    {activeSubmodule === 'borrowed' && 'Tools that other users are currently borrowing.'}
                                    {activeSubmodule === 'available' && 'Tools that are available for usage.'}
                                    {activeSubmodule === 'all' && 'Complete inventory of all tools in the system.'}
                                </p>
                            </div>

                            {/* Search Bar */}
                            <div className="mb-8">
                                <div className="relative max-w-xl">
                                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                                    <input
                                        type="text"
                                        placeholder="Search tools..."
                                        value={searchQuery}
                                        onChange={(e) => setSearchQuery(e.target.value)}
                                        className="w-full pl-12 pr-4 py-3 bg-white border border-slate-300 rounded-xl 
                                            focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                                            text-slate-900 placeholder-slate-400"
                                    />
                                </div>
                            </div>

                            {/* Error Message */}
                            {error && (
                                <div className="bg-red-50 border border-red-200 rounded-xl p-4 mb-8">
                                    <p className="text-red-800 font-medium">Error: {error}</p>
                                </div>
                            )}

                            {/* Loading State */}
                            {loading ? (
                                <div className="flex items-center justify-center py-20">
                                    <Loader2 className="w-12 h-12 text-indigo-600 animate-spin" />
                                </div>
                            ) : (
                                <>
                                    {/* Tools Grid */}
                                    {displayTools.length > 0 ? (
                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                                            {displayTools.map((tool) =>
                                                renderToolCard(tool, activeSubmodule)
                                            )}
                                        </div>
                                    ) : (
                                        <div className="text-center py-20">
                                            <Package className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                                            <h3 className="text-xl font-bold text-slate-900 mb-2">No tools found</h3>
                                            <p className="text-slate-600">
                                                {searchQuery
                                                    ? 'Try adjusting your search criteria'
                                                    : 'There are no tools in this category'}
                                            </p>
                                        </div>
                                    )}

                                </>
                            )}
                        </>
                    )}

                    {activeModule === 'users' && (
                        <div className="text-center py-20">
                            <UsersComp />
                        </div>
                    )}

                    {activeModule === 'history' && (
                        <History />
                    )}
                </main>
            </div>

            {/* Overlay for mobile */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 bg-black bg-opacity-50 z-30 lg:hidden"
                    onClick={() => setSidebarOpen(false)}
                />
            )}
        </div>
    );
};

export default Inventory;