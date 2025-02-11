state("Breaker-Win64-Shipping")
{
	uint bossCount: "Breaker-Win64-Shipping.exe", 0x61054F0;
	uint prismCount: "Breaker-Win64-Shipping.exe", 0x6105500;
	uint extractCount: "Breaker-Win64-Shipping.exe", 0x6322010, 0x30, 0x2b0, 0x3f0, 0xb0, 0x400, 0x260, 0x68;
	ulong brightBloodCache: "Breaker-Win64-Shipping.exe", 0x6326300, 0x8, 0x8, 0x720, 0x540, 0x260, 0x138;
	ulong brightBloodVault: "Breaker-Win64-Shipping.exe", 0x61E1E30, 0x40, 0x118, 0xa0, 0xd0, 0xd28, 0x318;
	float playerXCoord: "Breaker-Win64-Shipping.exe", 0x6322010, 0x30, 0x120, 0xb0, 0x100;
	float playerYCoord: "Breaker-Win64-Shipping.exe", 0x6322010, 0x30, 0x120, 0xb0, 0x104;
	float playerZCoord: "Breaker-Win64-Shipping.exe", 0x6322010, 0x30, 0x120, 0xb0, 0x108;
	//ushort wButtons: "XINPUT1_3.dll", 0x7651, 0x40;
	uint inputCount: "gameoverlayrenderer64.dll", 0x17BB60;
	uint teleportRestartAmount_preReport: "Breaker-Win64-Shipping.exe", 0x6322010, 0x30, 0x2b0, 0x3f0, 0x1e8, 0x3f0, 0x278, 0x594;
	uint teleportRestartAmount_postReport: "Breaker-Win64-Shipping.exe", 0x5F48B80, 0x110, 0x40, 0x268, 0x170, 0x288, 0xbc8, 0x894;
	byte isLoading: "Breaker-Win64-Shipping.exe", 0x61E4339;
	uint worldState: "Breaker-Win64-Shipping.exe", 0x5FF6D78;
}

init
{
	vars.taintedStart = 0;
	vars.extractTrigger = 0;
	vars.inRun = 0;
	vars.startWatch = 0;
	vars.startTrigger = 0;
}

update
{
	// reset to fresh state;
	vars.startTrigger = 0;
	
	// print("hello");
	
	// detect loading into gameworld;
	if (current.worldState == 0 && old.worldState == 1)
	{
		print("dropped into run");
		vars.startWatch = 1;
	}
	
	// trigger start on user input;
	if (vars.startWatch == 1)
	{
		print("watching for user input");
		if (current.inputCount != old.inputCount)
		{
			print("user input detected, lets go!");
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
		print("prism acquired!");
		return true;
	}
	
	// split on boss kill
	if (current.bossCount == old.bossCount+1)
	{
		print("boss downed!");
		return true;
	}
	
	// split on extract
	if (current.extractCount == 4 && old.extractCount == 3)
	{
		print("extracted!");
		return true;
	}
	
	// split on end screen
	if (current.teleportRestartAmount_preReport != old.teleportRestartAmount_preReport)
	{
		print("cycle screen reached!");
		return true;
	}
}