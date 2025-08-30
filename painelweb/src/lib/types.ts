export interface Property {
    id: number;
    code: string | null;
    title: string;
    type: string;
    status: string;
    price: number;
    city: string;
    broker_id: number;
    broker_name?: string;
    sale_value?: number;
    commission_value?: number;
    commission_rate?: number;
    created_at: string;
}

export interface Broker {
    id: number;
    name: string;
    email: string;
    creci: string;
    created_at: string;
    property_count?: number;
}

export interface User {
    id: number;
    name: string;
    email: string;
    phone: string;
    created_at: string;
}

export type View = 'dashboard' | 'properties' | 'brokers' | 'users';

export type DataItem = Property | Broker | User;

