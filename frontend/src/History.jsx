import React, { useState, useEffect } from 'react';
import { Calendar, Search, Download, Loader2, Filter, X, RefreshCw } from 'lucide-react';

const API_BASE_URL = import.meta.env.VITE_BASE_URL; // Update with your actual API URL

const History = () => {
    const [historyData, setHistoryData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [searchQuery, setSearchQuery] = useState('');

    // Date filters - default to current month
    const getDefaultStartDate = () => {
        const date = new Date();
        return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-01`;
    };

    const getDefaultEndDate = () => {
        const date = new Date();
        return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
    };

    const [startDate, setStartDate] = useState(getDefaultStartDate());
    const [endDate, setEndDate] = useState(getDefaultEndDate());
    const [tempStartDate, setTempStartDate] = useState(getDefaultStartDate());
    const [tempEndDate, setTempEndDate] = useState(getDefaultEndDate());
    const [showFilters, setShowFilters] = useState(false);

    // Fetch history data
    useEffect(() => {
        fetchHistory();
    }, []);

    const fetchHistory = async (start = startDate, end = endDate) => {
        try {
            setLoading(true);
            setError(null);
            const response = await fetch(`${API_BASE_URL}/inventory/history?start=${start}&end=${end}`);
            if (!response.ok) throw new Error('Failed to fetch history');
            const data = await response.json();
            setHistoryData(data);
        } catch (err) {
            setError(err.message);
            console.error('Error fetching history:', err);
        } finally {
            setLoading(false);
        }
    };

    // Apply date filters
    const applyFilters = () => {
        setStartDate(tempStartDate);
        setEndDate(tempEndDate);
        fetchHistory(tempStartDate, tempEndDate);
        setShowFilters(false);
    };

    // Reset filters to current month
    const resetFilters = () => {
        const defaultStart = getDefaultStartDate();
        const defaultEnd = getDefaultEndDate();
        setTempStartDate(defaultStart);
        setTempEndDate(defaultEnd);
        setStartDate(defaultStart);
        setEndDate(defaultEnd);
        fetchHistory(defaultStart, defaultEnd);
        setShowFilters(false);
    };

    // Format date for display
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    // Calculate duration
    const calculateDuration = (borrowedAt, returnedAt) => {
        const borrowed = new Date(borrowedAt);
        const returned = new Date(returnedAt);
        const diffMs = returned - borrowed;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffDays > 0) {
            return `${diffDays}d ${diffHours % 24}h`;
        } else if (diffHours > 0) {
            return `${diffHours}h ${diffMins % 60}m`;
        } else {
            return `${diffMins}m`;
        }
    };

    // Filter history based on search query
    const filterHistory = () => {
        if (!searchQuery) return historyData;

        const searchLower = searchQuery.toLowerCase();
        return historyData.filter(record => {
            const borrowerMatch = record.borrower?.toLowerCase().includes(searchLower);
            const toolMatch = record.tool?.toLowerCase().includes(searchLower);
            const descMatch = record.description?.toLowerCase().includes(searchLower);
            const classMatch = record.classification?.toLowerCase().includes(searchLower);

            return borrowerMatch || toolMatch || descMatch || classMatch;
        });
    };

    // Export to CSV
    const exportToCSV = () => {
        const headers = ['Borrower', 'Tool', 'Description', 'Classification', 'Borrowed At', 'Returned At', 'Duration', 'Status'];
        const rows = filterHistory().map(record => [
            record.borrower,
            record.tool,
            record.description || '',
            record.classification,
            formatDate(record.borrowedAt),
            formatDate(record.returnedAt),
            calculateDuration(record.borrowedAt, record.returnedAt),
            record.status
        ]);

        const csvContent = [
            headers.join(','),
            ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
        ].join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `tool-history-${startDate}-to-${endDate}.csv`;
        a.click();
        window.URL.revokeObjectURL(url);
    };

    const filteredHistory = filterHistory();

    // Calculate statistics
    const totalTransactions = filteredHistory.length;
    const uniqueBorrowers = new Set(filteredHistory.map(r => r.borrower)).size;
    const uniqueTools = new Set(filteredHistory.map(r => r.tool)).size;

    return (
        <div className="space-y-6">
            {/* Header Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-indigo-100 rounded-lg">
                            <RefreshCw className="w-6 h-6 text-indigo-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Total Transactions</p>
                            <p className="text-2xl font-bold text-slate-900">{totalTransactions}</p>
                        </div>
                    </div>
                </div>

                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-blue-100 rounded-lg">
                            <Calendar className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Unique Borrowers</p>
                            <p className="text-2xl font-bold text-slate-900">{uniqueBorrowers}</p>
                        </div>
                    </div>
                </div>

                <div className="bg-white border border-slate-200 rounded-xl p-6">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-emerald-100 rounded-lg">
                            <Calendar className="w-6 h-6 text-emerald-600" />
                        </div>
                        <div>
                            <p className="text-sm text-slate-600">Unique Tools</p>
                            <p className="text-2xl font-bold text-slate-900">{uniqueTools}</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Controls */}
            <div className="flex flex-col md:flex-row gap-4">
                {/* Search Bar */}
                <div className="relative flex-1">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                    <input
                        type="text"
                        placeholder="Search by borrower, tool, description, or classification..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-12 pr-4 py-3 bg-white border border-slate-300 rounded-xl 
                            focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                            text-slate-900 placeholder-slate-400"
                    />
                </div>

                {/* Filter Button */}
                <button
                    onClick={() => setShowFilters(!showFilters)}
                    className="flex items-center gap-2 px-6 py-3 bg-white border border-slate-300 rounded-xl hover:bg-slate-50 transition-colors font-semibold text-slate-700"
                >
                    <Filter className="w-5 h-5" />
                    Filters
                </button>

                {/* Export Button */}
                <button
                    onClick={exportToCSV}
                    disabled={filteredHistory.length === 0}
                    className="flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition-colors font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <Download className="w-5 h-5" />
                    Export CSV
                </button>
            </div>

            {/* Date Filter Panel */}
            {showFilters && (
                <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-lg">
                    <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-bold text-slate-900">Date Range</h3>
                        <button
                            onClick={() => setShowFilters(false)}
                            className="p-2 hover:bg-slate-100 rounded-lg transition-colors"
                        >
                            <X className="w-5 h-5 text-slate-600" />
                        </button>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                            <label className="block text-sm font-semibold text-slate-700 mb-2">
                                Start Date
                            </label>
                            <input
                                type="date"
                                value={tempStartDate}
                                onChange={(e) => setTempStartDate(e.target.value)}
                                className="w-full px-4 py-3 bg-white border border-slate-300 rounded-xl 
                                    focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                                    text-slate-900"
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-semibold text-slate-700 mb-2">
                                End Date
                            </label>
                            <input
                                type="date"
                                value={tempEndDate}
                                onChange={(e) => setTempEndDate(e.target.value)}
                                className="w-full px-4 py-3 bg-white border border-slate-300 rounded-xl 
                                    focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                                    text-slate-900"
                            />
                        </div>
                    </div>

                    <div className="flex gap-3">
                        <button
                            onClick={applyFilters}
                            className="flex-1 px-6 py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition-colors font-semibold"
                        >
                            Apply Filters
                        </button>
                        <button
                            onClick={resetFilters}
                            className="px-6 py-3 bg-slate-100 text-slate-700 rounded-xl hover:bg-slate-200 transition-colors font-semibold"
                        >
                            Reset
                        </button>
                    </div>
                </div>
            )}

            {/* Active Date Range Display */}
            <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
                <p className="text-indigo-900 font-medium">
                    Showing history from <span className="font-bold">{new Date(startDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</span>
                    {' '}to{' '}
                    <span className="font-bold">{new Date(endDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</span>
                </p>
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
                    {/* History Table */}
                    {filteredHistory.length > 0 ? (
                        <div className="bg-white border border-slate-200 rounded-xl overflow-hidden">
                            <div className="overflow-x-auto">
                                <table className="w-full">
                                    <thead className="bg-slate-50 border-b border-slate-200">
                                        <tr>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Borrower</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Tool</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Description</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Classification</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Borrowed At</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Returned At</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Duration</th>
                                            <th className="px-6 py-4 text-left text-sm font-bold text-slate-900">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-200">
                                        {filteredHistory.map((record, index) => (
                                            <tr key={index} className="hover:bg-slate-50 transition-colors">
                                                <td className="px-6 py-4 text-sm text-slate-900 font-medium">{record.borrower}</td>
                                                <td className="px-6 py-4 text-sm text-slate-900">{record.tool}</td>
                                                <td className="px-6 py-4 text-sm text-slate-600">{record.description || '-'}</td>
                                                <td className="px-6 py-4 text-sm">
                                                    <span className={`inline-flex px-3 py-1 rounded-full text-xs font-semibold ${record.classification.toLowerCase() === 'student'
                                                        ? 'bg-blue-100 text-blue-700'
                                                        : 'bg-emerald-100 text-emerald-700'
                                                        }`}>
                                                        {record.classification}
                                                    </span>
                                                </td>
                                                <td className="px-6 py-4 text-sm text-slate-600">{formatDate(record.borrowedAt)}</td>
                                                <td className="px-6 py-4 text-sm text-slate-600">{formatDate(record.returnedAt)}</td>
                                                <td className="px-6 py-4 text-sm text-slate-600 font-medium">
                                                    {calculateDuration(record.borrowedAt, record.returnedAt)}
                                                </td>
                                                <td className="px-6 py-4 text-sm">
                                                    <span className={`inline-flex px-3 py-1 rounded-full text-xs font-semibold ${record.status === 'available'
                                                        ? 'bg-green-100 text-green-700'
                                                        : 'bg-yellow-100 text-yellow-700'
                                                        }`}>
                                                        {record.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    ) : (
                        <div className="text-center py-20 bg-white border border-slate-200 rounded-xl">
                            <Calendar className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                            <h3 className="text-xl font-bold text-slate-900 mb-2">No history found</h3>
                            <p className="text-slate-600">
                                {searchQuery
                                    ? 'Try adjusting your search criteria or date range'
                                    : 'No borrowing history available for the selected date range'}
                            </p>
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

export default History;