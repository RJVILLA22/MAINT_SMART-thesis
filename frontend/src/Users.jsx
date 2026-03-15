import React, { useState, useEffect } from 'react';
import { Search, User, GraduationCap, Briefcase, Loader2, Package, Calendar, AlertCircle } from 'lucide-react';

const API_BASE_URL = import.meta.env.VITE_BASE_URL // Update with your actual API URL

const UsersComp = () => {
    const [users, setUsers] = useState({ students: [], instructors: [] });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [activeTab, setActiveTab] = useState('all'); // 'all', 'students', 'instructors'
    const [hoveredUser, setHoveredUser] = useState(null);
    const [borrowedTools, setBorrowedTools] = useState({});
    const [loadingTools, setLoadingTools] = useState({});

    // Fetch all users grouped by type
    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            setError(null);
            const response = await fetch(`${API_BASE_URL}/users/grouped`);
            if (!response.ok) throw new Error('Failed to fetch users');
            const data = await response.json();
            setUsers(data);
        } catch (err) {
            setError(err.message);
            console.error('Error fetching users:', err);
        } finally {
            setLoading(false);
        }
    };

    // Fetch borrowed tools for a specific user
    const fetchUserBorrowedTools = async (userId) => {
        if (borrowedTools[userId]) return; // Already fetched

        try {
            setLoadingTools(prev => ({ ...prev, [userId]: true }));
            const response = await fetch(`${API_BASE_URL}/inventory/borrowed/user/${userId}`);
            if (!response.ok) throw new Error('Failed to fetch borrowed tools');
            const data = await response.json();
            setBorrowedTools(prev => ({ ...prev, [userId]: data }));
        } catch (err) {
            console.error('Error fetching borrowed tools:', err);
            setBorrowedTools(prev => ({ ...prev, [userId]: [] }));
        } finally {
            setLoadingTools(prev => ({ ...prev, [userId]: false }));
        }
    };

    // Handle mouse enter on user card
    const handleUserHover = (userId) => {
        setHoveredUser(userId);
        fetchUserBorrowedTools(userId);
    };

    // Filter users based on search query
    const filterUsers = (userList) => {
        if (!searchQuery) return userList;

        const searchLower = searchQuery.toLowerCase();
        return userList.filter(user => {
            const nameMatch = `${user.first_name} ${user.last_name}`.toLowerCase().includes(searchLower);
            const idMatch = user.id_number?.toLowerCase().includes(searchLower);
            const emailMatch = user.email?.toLowerCase().includes(searchLower);
            const deptMatch = user.department?.toLowerCase().includes(searchLower);
            const courseMatch = user.course?.toLowerCase().includes(searchLower);

            return nameMatch || idMatch || emailMatch || deptMatch || courseMatch;
        });
    };

    // Get display users based on active tab
    const getDisplayUsers = () => {
        if (activeTab === 'students') {
            return filterUsers(users.students);
        } else if (activeTab === 'instructors') {
            return filterUsers(users.instructors);
        } else {
            return [...filterUsers(users.students), ...filterUsers(users.instructors)];
        }
    };

    // Format date helper
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    };

    const displayUsers = getDisplayUsers();
    const totalStudents = users.students.length;
    const totalInstructors = users.instructors.length;

    return (
        <div className="space-y-6">
            {/* Header Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-indigo-100 rounded-lg">
                            <User className="w-6 h-6 text-indigo-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Total Users</p>
                            <p className="text-2xl font-bold text-slate-900">{totalStudents + totalInstructors}</p>
                        </div>
                    </div>
                </div>

                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-blue-100 rounded-lg">
                            <GraduationCap className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Students</p>
                            <p className="text-2xl font-bold text-slate-900">{totalStudents}</p>
                        </div>
                    </div>
                </div>

                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-emerald-100 rounded-lg">
                            <Briefcase className="w-6 h-6 text-emerald-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Instructors</p>
                            <p className="text-2xl font-bold text-slate-900">{totalInstructors}</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-3">
                <button
                    onClick={() => setActiveTab('all')}
                    className={`
                        px-6 py-3 rounded-xl font-semibold transition-all duration-200
                        ${activeTab === 'all'
                            ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-200'
                            : 'bg-white text-slate-700 hover:bg-slate-50 border border-slate-200'
                        }
                    `}
                >
                    All Users
                </button>
                <button
                    onClick={() => setActiveTab('students')}
                    className={`
                        px-6 py-3 rounded-xl font-semibold transition-all duration-200
                        ${activeTab === 'students'
                            ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-200'
                            : 'bg-white text-slate-700 hover:bg-slate-50 border border-slate-200'
                        }
                    `}
                >
                    Students
                </button>
                <button
                    onClick={() => setActiveTab('instructors')}
                    className={`
                        px-6 py-3 rounded-xl font-semibold transition-all duration-200
                        ${activeTab === 'instructors'
                            ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-200'
                            : 'bg-white text-slate-700 hover:bg-slate-50 border border-slate-200'
                        }
                    `}
                >
                    Instructors
                </button>
            </div>

            {/* Search Bar */}
            <div className="relative max-w-xl">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                    type="text"
                    placeholder="Search by name, ID, email, department, or course..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-12 pr-4 py-3 bg-white border border-slate-300 rounded-xl 
                        focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                        text-slate-900 placeholder-slate-400"
                />
            </div>

            {/* Error Message */}
            {error && (
                <div className="bg-red-50 border border-red-200 rounded-xl p-4">
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
                    {/* Users Grid */}
                    {displayUsers.length > 0 ? (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {displayUsers.map((user) => {
                                const isStudent = user.type.toLowerCase() === 'student';
                                const userBorrowedTools = borrowedTools[user.id] || [];
                                const isLoadingTools = loadingTools[user.id];
                                const isHovered = hoveredUser === user.id;

                                return (
                                    <div
                                        key={user.id}
                                        className="relative bg-white border border-slate-200 rounded-xl p-6 hover:border-indigo-300 hover:shadow-lg transition-all duration-300 cursor-pointer"
                                        onMouseEnter={() => handleUserHover(user.id)}
                                        onMouseLeave={() => setHoveredUser(null)}
                                    >
                                        {/* User Card Content */}
                                        <div className="flex items-start gap-4">
                                            <div className={`p-3 rounded-lg ${isStudent ? 'bg-blue-100' : 'bg-emerald-100'}`}>
                                                {isStudent ? (
                                                    <GraduationCap className={`w-6 h-6 ${isStudent ? 'text-blue-600' : 'text-emerald-600'}`} />
                                                ) : (
                                                    <Briefcase className="w-6 h-6 text-emerald-600" />
                                                )}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <h3 className="text-lg font-bold text-slate-900 truncate">
                                                    {user.first_name} {user.last_name}
                                                </h3>
                                                <p className="text-sm text-slate-600 mb-2">
                                                    {isStudent ? 'Student' : 'Instructor'}
                                                </p>
                                                <div className="space-y-1">
                                                    {user.id_number && (
                                                        <p className="text-sm text-slate-600">
                                                            <span className="font-semibold">ID:</span> {user.id_number}
                                                        </p>
                                                    )}
                                                    <p className="text-sm text-slate-600 truncate">
                                                        <span className="font-semibold">Email:</span> {user.email}
                                                    </p>
                                                    {user.department && (
                                                        <p className="text-sm text-slate-600 truncate">
                                                            <span className="font-semibold">Dept:</span> {user.department}
                                                        </p>
                                                    )}
                                                    {user.course && (
                                                        <p className="text-sm text-slate-600 truncate">
                                                            <span className="font-semibold">Course:</span> {user.course}
                                                        </p>
                                                    )}
                                                </div>

                                                {/* Borrowed Tools Count Badge */}
                                                {userBorrowedTools.length > 0 && (
                                                    <div className="mt-3 inline-flex items-center gap-2 px-3 py-1 bg-yellow-50 border border-yellow-200 rounded-lg">
                                                        <Package className="w-4 h-4 text-yellow-600" />
                                                        <span className="text-sm font-semibold text-yellow-700">
                                                            {userBorrowedTools.length} {userBorrowedTools.length === 1 ? 'tool' : 'tools'} borrowed
                                                        </span>
                                                    </div>
                                                )}
                                            </div>
                                        </div>

                                        {/* Hover Tooltip - Borrowed Tools */}
                                        {isHovered && (
                                            <div className="absolute left-full top-0 ml-4 w-80 bg-white border border-slate-300 rounded-xl shadow-2xl p-4 z-50 animate-in fade-in slide-in-from-left-2 duration-200">
                                                <div className="flex items-center gap-2 mb-3 pb-3 border-b border-slate-200">
                                                    <Package className="w-5 h-5 text-indigo-600" />
                                                    <h4 className="font-bold text-slate-900">Borrowed Tools</h4>
                                                </div>

                                                {isLoadingTools ? (
                                                    <div className="flex items-center justify-center py-8">
                                                        <Loader2 className="w-6 h-6 text-indigo-600 animate-spin" />
                                                    </div>
                                                ) : userBorrowedTools.length > 0 ? (
                                                    <div className="space-y-3 max-h-96 overflow-y-auto">
                                                        {userBorrowedTools.map((tool, index) => {
                                                            const isOverdue = tool.dueDate && new Date(tool.dueDate) < new Date();

                                                            return (
                                                                <div
                                                                    key={index}
                                                                    className="p-3 bg-slate-50 rounded-lg border border-slate-200"
                                                                >
                                                                    <p className="font-semibold text-slate-900 mb-2">{tool.model}</p>
                                                                    <div className="space-y-1 text-xs">
                                                                        <div className="flex items-center gap-2 text-slate-600">
                                                                            <Calendar className="w-3 h-3" />
                                                                            <span>Borrowed: {formatDate(tool.borrowedAt)}</span>
                                                                        </div>
                                                                        <div className={`flex items-center gap-2 ${isOverdue ? 'text-red-600 font-semibold' : 'text-slate-600'}`}>
                                                                            <Calendar className="w-3 h-3" />
                                                                            <span>Due: {formatDate(tool.dueDate)}</span>
                                                                            {isOverdue && (
                                                                                <span className="ml-auto px-2 py-0.5 bg-red-100 text-red-700 rounded text-xs font-bold">
                                                                                    OVERDUE
                                                                                </span>
                                                                            )}
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            );
                                                        })}
                                                    </div>
                                                ) : (
                                                    <div className="text-center py-8">
                                                        <AlertCircle className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                                                        <p className="text-sm text-slate-600">No borrowed tools</p>
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                );
                            })}
                        </div>
                    ) : (
                        <div className="text-center py-20">
                            <User className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                            <h3 className="text-xl font-bold text-slate-900 mb-2">No users found</h3>
                            <p className="text-slate-600">
                                {searchQuery
                                    ? 'Try adjusting your search criteria'
                                    : 'No users available in this category'}
                            </p>
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

export default UsersComp;