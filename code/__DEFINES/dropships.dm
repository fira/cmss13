// Legacy identifiers of dropship hardpoint/equipment types
#define DROPSHIP_WEAPON "dropship_weapon"
#define DROPSHIP_CREW_WEAPON "dropship_crew_weapon"
#define DROPSHIP_ELECTRONICS "dropship_electronics"
#define DROPSHIP_FUEL_EQP "dropship_fuel_equipment"
#define DROPSHIP_COMPUTER "dropship_computer"

//Automated transport
#define DROPSHIP_MAX_AUTO_DELAY 60 SECONDS
#define DROPSHIP_MIN_AUTO_DELAY 10 SECONDS
#define DROPSHIP_AUTO_RETRY_COOLDOWN 20 SECONDS

/// CAS solution can be/is used for direct fire
#define CAS_MODE_DIRECT (1<<0)
/// CAS solution can be/is used for fire missions
#define CAS_MODE_FM (1<<1)

#define CAS_FIRING_IDLE 0
#define CAS_FIRING_FIRED 1
#define CAS_FIRING_TERMINAL 2
#define CAS_FIRING_IMPACT 3

