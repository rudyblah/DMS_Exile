/*
	Sample mission (duplicate for testing purposes)
*/

private ["_num", "_side", "_pos", "_difficulty", "_AICount", "_group", "_crate", "_crate_loot_values", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_missionAIUnits", "_missionObjs", "_markers", "_time", "_added"];

// For logging purposes
_num = DMS_MissionCount;


// Set mission side (only "bandit" is supported for now)
_side = "bandit";


// find position
_pos = call DMS_findSafePos;


// Set general mission difficulty
_difficulty = "moderate";


// Create AI
// TODO: Spawn AI only when players are nearby
_AICount = 6 + (round (random 2));

_group =
[
	_pos,					// Position of AI
	_AICount,				// Number of AI
	"random",				// "random","hardcore","difficult","moderate", or "easy"
	"random", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side 					// "bandit","hero", etc.
] call DMS_SpawnAIGroup;


// Create Crate
_crate = createVehicle ["Box_NATO_Wps_F",_pos,[], 0, "CAN_COLLIDE"];

// Set crate loot values
_crate_loot_values =
[
	5,		// Weapons
	10,		// Items
	3 		// Backpacks
];


// Define mission-spawned AI Units
_missionAIUnits =
[
	_group 		// We only spawned the single group for this mission
];

// Define mission-spawned objects and loot values
_missionObjs =
[
	[],			// No spawned buildings
	[_crate],
	_crate_loot_values
];

// Define Mission Start message
_msgStart = format["A group of mercenaries has been spotted at %1! Kill them and take their equipment!",mapGridPosition _pos];

// Define Mission Win message
_msgWIN = format["Convicts have successfully eliminated the mercenaries at %1!",mapGridPosition _pos];

// Define Mission Lose message
_msgLOSE = format["The mercenaries are no longer at %1!",mapGridPosition _pos];


// Define mission name (for map marker and logging)
_missionName = "Mercenary Group4";

// Create Markers
_markers =
[
	_pos,
	_missionName,
	_difficulty
] call DMS_CreateMarker;

// Record time here (for logging purposes, otherwise you could just put "diag_tickTime" into the "DMS_AddMissionToMonitor" parameters directly)
_time = diag_tickTime;

// Parse and add mission info to missions monitor
_added =
[
	_pos,
	[
		[
			"kill",
			_group
		],
		[
			"playerNear",
			[_pos,DMS_playerNearRadius]
		]
	],
	[
		_time,
		(DMS_MissionTimeOut select 0) + random((DMS_MissionTimeOut select 1) - (DMS_MissionTimeOut select 0))
	],
	_missionAIUnits,
	_missionObjs,
	[_msgWIN,_msgLOSE],
	_markers,
	_side
] call DMS_AddMissionToMonitor;

// Check to see if it was added correctly, otherwise delete the stuff
if !(_added) exitWith
{
	diag_log format ["DMS ERROR :: Attempt to set up mission %1 with invalid parameters for DMS_AddMissionToMonitor! Deleting mission objects and resetting DMS_MissionCount.",_missionName];

	// Delete AI units and the crate. I could do it in one line but I just made a little function that should work for every mission (provided you defined everything correctly)
	_cleanup = [];
	{
		_cleanup pushBack _x;
		false;
	} count _missionAIUnits;

	_cleanup pushBack ((_missionObjs select 0)+(_missionObjs select 1));

	_cleanup call DMS_CleanUp;


	// Delete the markers directly
	{deleteMarker _x;false;} count _markers;


	// Reset the mission count
	DMS_MissionCount = DMS_MissionCount - 1;
};


// Notify players
_msgStart call DMS_BroadcastMissionStatus;



if (DMS_DEBUG) then
{
	diag_log format ["DMS_DEBUG MISSION: (%1) :: Mission #%2 started at %3 with %4 AI units and %5 difficulty at time %6",_missionName,_num,_pos,_AICount,_difficulty,_time];
};