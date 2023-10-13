// generated by "sampctl package init"
#include <a_samp>
#include <streamer>
#include <zcmd>
#include <sscanf2>

new 
	DB:db_handle,
	query[5000],
	bool:pCreatingGangzone[MAX_PLAYERS];

enum gangzoneData{
    gangzoneName[48],
    gangzoneDBID,
    gangzoneID,
    bool:gangzoneExist,
    gangzoneOwner,
    gangzoneColor,
    Float:gangzoneMinX,
    Float:gangzoneMinY,
    Float:gangzoneMaxX,
    Float:gangzoneMaxY,
    gangzoneArea
} new GangzoneData[MAX_GANG_ZONES][gangzoneData];

public OnFilterScriptInit()
{
	if((db_handle = db_open("gangzones.db")) == DB:0) {
        print("could not find \"gangzones.db\".");
        SendRconCommand("exit");
    }else { print("\"gangzones.db\" connected!"); }

	new DBResult:result, i=1;
    result = db_query(db_handle, "SELECT * FROM `gangzones`");
    if(db_num_rows(result) > 0)
	{
		do
		{
			GangzoneData[i][gangzoneExist] = true;
            GangzoneData[i][gangzoneDBID] = db_get_field_assoc_int(result,"gzID");
			db_get_field_assoc(result,"gzName", GangzoneData[i][gangzoneName], 48);
           	GangzoneData[i][gangzoneOwner] = db_get_field_assoc_int(result,"gzOwner");
           	GangzoneData[i][gangzoneColor] = db_get_field_assoc_int(result,"gzColor");
           	GangzoneData[i][gangzoneMinX] = db_get_field_assoc_float(result,"gzMinX");
           	GangzoneData[i][gangzoneMinY] = db_get_field_assoc_float(result,"gzMinY");
           	GangzoneData[i][gangzoneMaxX] = db_get_field_assoc_float(result,"gzMaxX");
           	GangzoneData[i][gangzoneMaxY] = db_get_field_assoc_float(result,"gzMaxY");
			Gangzone_Refresh(i);
            i++;
		}
		while(db_next_row(result));
	}
	db_free_result(result);
    return 1;
}

public OnPlayerSpawn(playerid) 
{
    GangzonesShowForPlayer(playerid);
	return 1;
}

CMD:creategangzone(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, -1, "You do not have permission.");
    
    if(!pCreatingGangzone[playerid])
    {
        static Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPVarFloat(playerid, "gzMinX", x);
        SetPVarFloat(playerid, "gzMinY", y);
        SendClientMessage(playerid, -1, "The minimum position of the gangzone has been defined, go to the maximum position and use '/creategangzone' again.");
        pCreatingGangzone[playerid] = true;
    }
    else{
        static Float:maxx, Float:maxy, Float:z, name[48], string[128];
        if (sscanf(params, "s[48]", name))
	        return SendClientMessage(playerid, -1, "/creategangzone [name]");
        
        if(strlen(name) > 24)  
            return SendClientMessage(playerid, -1, "The name must be 1 to 24 characters long.");

        new Float:minx = GetPVarFloat(playerid, "gzMinX");
        new Float:miny = GetPVarFloat(playerid, "gzMinY");
        DeletePVar(playerid, "gzMinX");
        DeletePVar(playerid, "gzMinY");

        GetPlayerPos(playerid, maxx, maxy, z);
        new gangzoneid = Gangzone_Create(name, minx, miny, maxx, maxy);
        if(gangzoneid != -1){
			format(string, sizeof(string), "Gangzone %s was created successfully and has no owner.", name);
            SendClientMessage(playerid, -1, string);
		}
        else return SendClientMessage(playerid, -1, "The server has reached the maximum limit of allowed gangzones, contact the developer.");
    }
    return 1;
}

CMD:destroygangzone(playerid, params[])
{
	static
	    id = 0,
		string[128];

    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, -1, "You do not have permission.");

	if (sscanf(params, "d", id))
	    return SendClientMessage(playerid, -1, "/destroygangzone [ID]");

	if ((id < 0 || id >= MAX_GANG_ZONES) || !GangzoneData[id][gangzoneExist])
	    return SendClientMessage(playerid, -1, "You did not specify a valid gangzone ID.");

	Gangzone_Delete(id);
	format(string, sizeof(string), "You have successfully destroyed gangzone ID: %d.", id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

forward Gangzone_Create(name[48], Float:minx, Float:miny, Float:maxx, Float:maxy);
public Gangzone_Create(name[48], Float:minx, Float:miny, Float:maxx, Float:maxy)
{
    for(new i=1; i < MAX_GANG_ZONES; i++)
    {
        if(!GangzoneData[i][gangzoneExist])
        {
            GangzoneData[i][gangzoneExist] = true;
            format(GangzoneData[i][gangzoneName], 48, name);
            GangzoneData[i][gangzoneMinX] = minx;
            GangzoneData[i][gangzoneMinY] = miny;
            GangzoneData[i][gangzoneMaxX] = maxx;
            GangzoneData[i][gangzoneMaxY] = maxy;
            GangzoneData[i][gangzoneOwner] = 0;
            GangzoneData[i][gangzoneColor] = 0xB4B5B7FF;
            Gangzone_Refresh(i);

            format(query, sizeof(query), "INSERT INTO `gangzones` (`gzName`, `gzOwner`, `gzColor`, `gzMinX`, `gzMinY`, `gzMaxX`, `gzMaxY`) VALUES('%s', %d, %d, %f, %f, %f, %f)",
                GangzoneData[i][gangzoneName],
                GangzoneData[i][gangzoneOwner],
                GangzoneData[i][gangzoneColor],
                GangzoneData[i][gangzoneMinX],
                GangzoneData[i][gangzoneMinY],
                GangzoneData[i][gangzoneMaxX],
                GangzoneData[i][gangzoneMaxY]);
            new DBResult:result = db_query(db_handle, query);
            printf(query);
            db_free_result(result);
            return i;
        }
    }
    return -1;
}

Gangzone_Delete(gzid)
{
	if (gzid != -1 && GangzoneData[gzid][gangzoneExist])
	{
        static 
            string[128];
            
		format(string, sizeof(string), "DELETE FROM `gangzones` WHERE `gzID` = '%d'", GangzoneData[gzid][gangzoneDBID]);
		new DBResult:result = db_query(db_handle, string);
		db_free_result(result);

        GangZoneHideForAll(GangzoneData[gzid][gangzoneID]);
        GangZoneDestroy(GangzoneData[gzid][gangzoneID]);
        DestroyDynamicArea(GangzoneData[gzid][gangzoneArea]);

	    GangzoneData[gzid][gangzoneExist] = false;
	    GangzoneData[gzid][gangzoneOwner] = 0;
	    GangzoneData[gzid][gangzoneID] = 0;
	}
	return 1;
}

Gangzone_Refresh(gzid)
{
	if (gzid != -1 && GangzoneData[gzid][gangzoneExist])
	{
		GangzoneData[gzid][gangzoneID] = GangZoneCreate(GangzoneData[gzid][gangzoneMinX], GangzoneData[gzid][gangzoneMinY], GangzoneData[gzid][gangzoneMaxX], GangzoneData[gzid][gangzoneMaxY]);
        GangZoneShowForAll(GangzoneData[gzid][gangzoneID], GangzoneData[gzid][gangzoneColor]);
        GangzoneData[gzid][gangzoneArea] = CreateDynamicRectangle(GangzoneData[gzid][gangzoneMinX], GangzoneData[gzid][gangzoneMinY], GangzoneData[gzid][gangzoneMaxX], GangzoneData[gzid][gangzoneMaxY]);
	}
	return 1;
}

/*Gangzone_Save(gzid)
{
	format(query, sizeof(query), "UPDATE `gangzones` SET `gzName` = '%s', `gzOwner` = '%d', `gzColor` = '%d', `gzMinX` = '%f', `gzMinY` = '%f', `gzMaxX` = '%f', `gzMaxY` = '%f' WHERE `gzID` = '%d'",
  	GangzoneData[gzid][gangzoneName],
    GangzoneData[gzid][gangzoneOwner],
  	GangzoneData[gzid][gangzoneColor],
  	GangzoneData[gzid][gangzoneMinX],
 	GangzoneData[gzid][gangzoneMinY],
  	GangzoneData[gzid][gangzoneMaxX],
  	GangzoneData[gzid][gangzoneMaxY],
  	GangzoneData[gzid][gangzoneDBID]
 	);
 	new DBResult:result = db_query(db_handle, query);
	return db_free_result(result);
}*/

GangzonesShowForPlayer(playerid)
{
    for(new i=1; i < MAX_GANG_ZONES; i++)
    {
        if(GangzoneData[i][gangzoneExist])
            GangZoneShowForPlayer(playerid, GangzoneData[i][gangzoneID], GangzoneData[i][gangzoneColor]);
    }
    return 1;
}

stock Gangzone_Nearest(playerid)
{
    new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	for (new i=1; i < MAX_GANG_ZONES; i ++) {
        if(GangzoneData[i][gangzoneExist] && IsPlayerInDynamicArea(playerid, GangzoneData[i][gangzoneArea]))
            return i;
    }
	return -1;
}