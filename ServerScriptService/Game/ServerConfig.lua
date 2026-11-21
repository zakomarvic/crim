return {
	Gamemodes = {
		--["Beginners"] = {
		--	Enabled = true;
			
		--	PlaceIds = {
		--		[5305351181] = 8316387592; --brr
		--		[8296895215] = 8296895215; -- sL_test
		--		[7392688016] = 8321258197; -- bane
		--		[4588604953] = 8343259840; -- maingame
		--		[8966730058] = 8966725274; -- uno point 3
		--	};
		--	MaxPlayers = 30;
		--};
		["Casual"] = {
			Enabled = true;
			PlaceIds = {
				[5305351181] = 8316387592; --brr
				[8296895215] = 8296895215; -- sL_test
				[7392688016] = 8321258197; -- bane
				[4588604953] = 8343259840; -- maingame
				[8966730058] = 8966725274; -- uno point 3
			};
			MaxPlayers = 30;
		};
		
		["P-Casual"] = {
			Enabled = true;
			PlaceIds = {
				[5305351181] = 8316387592; --brr
				[8296895215] = 8296895215; -- sL_test
				[7392688016] = 8321258197; -- bane
				[4588604953] = 8343259840; -- maingame
				[8966730058] = 8966725274; -- uno point 3
			};
			MaxPlayers = 30;
		};
		
		["Standard"] = {
			Enabled = true;
			PlaceIds = {
				[5305351181] = 8316387592; --brr
				[8296895215] = 8296895215; -- sL_test
				[7392688016] = 8321258197; -- bane
				[4588604953] = 8343259840; -- maingame
				[8966730058] = 8966725274; -- uno point 3
			};
			MaxPlayers = 30;
		};
		
		--["Competitive"] = {
		--	Enabled = true;
		--	PlaceIds = {
		--		[5305351181] = 8316387592; --brr
		--		[8296895215] = 8296895215; -- sL_test
		--		[7392688016] = 8321258197; -- bane
		--		[4588604953] = 8343259840; -- maingame
		--	};
		--	MaxPlayers = 20;
		--};
	};

	MinRegionDistance = 750;
	--AllowRegionDistance = 30;
	SameRegionDistance = 500;
	MinHighestServerRegionDistance = 200;
	
	MinGamemodePlayerCount = 20;
	--MinGameModeServerCount = 10;

	ModBypass_MaxPlayers = true;
	ModBypass_JoinFriend = true;
	ActualMaxFull = 30;
	
	AccountAgeRequired = true;
		MinAccountAge = 14;
	VerifiedEmailRequired = true;
	
	ExistingServerTypes = {
		"GB";
		"US";
		"JP";
		"PL";
		"DE";
		"SG";
		"HK";
		"FR";
	};

	UpdateRate = 1.5;
	
	Servers = {
		["1857700501"] = 5305351181; -- brrr
		["2881451226"] = 7392688016; -- bane
		["1494262959"] = 4588604953; -- crim
	};
}