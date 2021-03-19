// Imports \\
import Connection from './Connection';

// Classes \\
declare class PremiumWrapper {
	/**
	 * Constructs the PremiumWrapper class, connects callbacks
	 */
	constructor()

	/**
	 * Returns whether the player given is a premium user
	 * @param player Required on the server, defaults to the LocalPlayer on the client
	 */
	PlayerIsPremium(player?: Player): boolean

	/**
	 * Binds a function to when a premium user joins, or is already in the server
	 * @param func The function to be ran, receieves the player who is the newly joined premium user
	 */
	BindOnPremiumJoin(func: (player: Player) => void): Connection

	/** 
	 * Binds a function to when a membership of a player changes
	 * @param func The function to be ran, recieves the player and if they're still a premium user
	*/
	BindOnMembershipChange(func: (player: Player, isPremium: boolean) => void): Connection

	/**
	 * Binds a tool to give to only premium users, revoked if they lose premium
	 * @param tool The tool to be given to premium users
	 */
	BindExclusiveTool(tool: Tool): void

	/**
	 * Binds a door which only premium users can walk through
	 * @param door The model or part which is the door
	 */
	BindExclusiveDoor(door: Model | BasePart): void

	/**
	 * Destroys the class instance and disconnects the internal connections
	 */
	Destroy(): void
}

// Exports \\
export = PremiumWrapper