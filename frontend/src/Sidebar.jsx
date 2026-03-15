import React from 'react';
import { ChevronRight, Package, Users, History } from 'lucide-react';

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

const SidebarComp = ({ sidebarOpen, activeModule, setActiveModule, activeSubmodule, setActiveSubmodule }) => {
    return (
        <aside
            className={`
                ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
                fixed lg:sticky top-[73px] left-0 h-[calc(100vh-73px)] w-72 
                bg-white border-r border-slate-200 
                transition-transform duration-300 ease-in-out z-40
                overflow-y-auto
            `}
        >
            <nav className="p-4 space-y-2">
                {modules.map((module) => {
                    const Icon = module.icon;
                    const isActive = activeModule === module.id;

                    return (
                        <div key={module.id}>
                            <button
                                onClick={() => {
                                    setActiveModule(module.id);
                                    if (module.submodules.length > 0) {
                                        setActiveSubmodule(module.submodules[0].id);
                                    }
                                }}
                                className={`
                                    w-full flex items-center gap-3 px-4 py-3 rounded-xl
                                    transition-all duration-200 font-semibold
                                    ${isActive
                                        ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-200'
                                        : 'text-slate-700 hover:bg-slate-100'
                                    }
                                `}
                            >
                                <Icon className="w-5 h-5" />
                                <span className="flex-1 text-left">{module.name}</span>
                                {module.submodules.length > 0 && (
                                    <ChevronRight className={`w-4 h-4 transition-transform ${isActive ? 'rotate-90' : ''}`} />
                                )}
                            </button>

                            {/* Submodules */}
                            {isActive && module.submodules.length > 0 && (
                                <div className="ml-4 mt-2 space-y-1 border-l-2 border-slate-200 pl-4">
                                    {module.submodules.map((sub) => (
                                        <button
                                            key={sub.id}
                                            onClick={() => setActiveSubmodule(sub.id)}
                                            className={`
                                                w-full text-left px-3 py-2 rounded-lg text-sm
                                                transition-colors duration-200
                                                ${activeSubmodule === sub.id
                                                    ? 'bg-indigo-50 text-indigo-700 font-semibold'
                                                    : 'text-slate-600 hover:bg-slate-50'
                                                }
                                            `}
                                        >
                                            {sub.name}
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>
                    );
                })}
            </nav>
        </aside>
    );
};

export default SidebarComp;