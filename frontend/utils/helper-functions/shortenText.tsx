

export function truncateWords(hash: string, amount: number, tail: string) {
    const words = hash.split(' ');
    if (amount >= words.length) {
        return hash;
    }
    const truncated = words.slice(0, amount);
    return `${truncated.join(' ')}${tail}`;
}