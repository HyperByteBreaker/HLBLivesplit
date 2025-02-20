state("Breaker-Win64-Shipping")
{
	uint bossCount: "Breaker-Win64-Shipping.exe", 0x611FE80;
	uint prismCount: "Breaker-Win64-Shipping.exe", 0x611FE90;
	uint extractCount: "Breaker-Win64-Shipping.exe", 0x633CD00, 0x30, 0x2b0, 0x400, 0xb0, 0x3f8, 0x260, 0x68;
	uint teleportRestartAmount: "Breaker-Win64-Shipping.exe", 0x5F61BA0, 0xb0, 0x40, 0x268, 0x160, 0x268, 0x2b0, 0x44;
	byte isLoading: "Breaker-Win64-Shipping.exe", 0x61C9DF0, 0x30, 0x98, 0xb8, 0x413;
	byte isInRun: "Breaker-Win64-Shipping.exe", 0x61c9df0, 0x30, 0xa8, 0x58, 0x268;
	float movementLR1: "Breaker-Win64-Shipping.exe", 0x6010FD0, 0x0, 0x1a0, 0x290, 0x160;
	float movementLR2: "Breaker-Win64-Shipping.exe", 0x6010FD0, 0x0, 0x190, 0x38, 0x160;
	float movementFB1: "Breaker-Win64-Shipping.exe", 0x6010FD0, 0x0, 0x190, 0x38, 0x164;
	float movementFB2: "Breaker-Win64-Shipping.exe", 0x6010FD0, 0x0, 0x1a0, 0x290, 0x164;
}

init
{
	vars.startWatch = 0;
	vars.startTrigger = 0;
	vars.runStarted = 0;
	vars.objectivesComplete = 0;
	vars.prismsComplete = 0;
	vars.bossesComplete = 0;
}

update
{	
	//print("[dbg] bc: " + current.bossCount + " " + vars.bossesComplete + " pc: " + current.prismCount + " " + vars.prismsComplete + " resAmt: " + current.teleportRestartAmount + " isLoading: " + current.isLoading + " world: " + current.isInRun);
	//print("[dbg] MFB:" + current.movementFB1 + " MLR: " + current.movementLR1 + " x: " + current.playerXCoord + " y: " + current.playerYCoord + " z: " + current.playerZCoord);	
	
	if (vars.startTrigger == 1)
	{
		vars.runStarted = 1;
		vars.startTrigger = 0;
	}
	
	// detect loading into gameworld
	if (current.isInRun == 1 && old.isInRun != 1)
	{
		print("[dbg] dropped into run bc: " + current.bossCount + " " + vars.bossesComplete + " pc: " + current.prismCount + " " + vars.prismsComplete);
		
		// only start on fresh run
		if (current.bossCount == 0 && current.prismCount == 0)
		{
			print("[dbg] run is fresh");
			vars.startWatch = 1;
		}
	}
	
	// trigger start on user movement;
	if (vars.startWatch == 1 && vars.runStarted == 0)
	{
		//print("[dbg] watching for user movement");
		if (current.movementFB1 != 0 || current.movementLR1 != 0)
		{
			print("[dbg] user movement detected, lets go!");
			vars.startTrigger = 1;
			vars.startWatch = 0;
		}
	}
}

isLoading
{
	return (current.isLoading == 1);
}

start
{
	return vars.startTrigger == 1;
}

split
{
	// split on prism acquisition
	if (current.prismCount == old.prismCount+1)
	{
		print("[dbg] prism acquired!");
		vars.prismsComplete = vars.prismsComplete+1;
		return true;
	}
	
	// split on boss kill
	if (current.bossCount == old.bossCount+1)
	{
		print("[dbg] boss downed!");
		vars.bossesComplete = vars.bossesComplete+1;
		return true;
	}
	
	// split on extract if all objectives complete
	if (vars.bossesComplete == 3 && vars.prismsComplete == 6)
	{
		if (current.extractCount == 4 && old.extractCount == 3)
		{
			print("[dbg] final extract!");
			return true;
		}
	}
	
	// split on end screen
	if (current.teleportRestartAmount != old.teleportRestartAmount)
	{
		print("[dbg] cycle screen reached!");
		vars.startTrigger = 0;
		vars.runStarted = 0;
		return true;
	}
}
