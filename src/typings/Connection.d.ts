// Classes \\
declare class Connection {
    public isConnected: boolean
    
    constructor(func: () => void)

    /**
     * Disconnects the connection - prevents it from running anymore and frees memory
     */
    public Disconnect(): void
}

// Exports \\
export = Connection