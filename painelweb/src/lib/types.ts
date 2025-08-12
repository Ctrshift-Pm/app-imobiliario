export type View = 'dashboard' | 'properties' | 'brokers' | 'users';

export interface Property {
    id: number;
    title: string;
    type: 'Casa' | 'Apartamento' | 'Terreno';
    status: 'Disponível' | 'Negociando' | 'Vendido' | 'Alugado';
    price: number;
    city: string;
    bedrooms: number;
    broker_id: number;
    created_at: string;
}

export interface Broker {
    id: number;
    name: string;
    email: string;
    creci: string;
    created_at: string;
}

export interface User {
    id: number;
    name: string;
    email: string;
    phone: string;
    created_at: string;
}
