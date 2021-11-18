/*
 * Copyright (C) 2021  Mikusch
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

void Console_Initialize()
{
	AddMultiTargetFilter("@prop", MultiTargetFilter_FilterProps, "Target: Props", true);
	AddMultiTargetFilter("@props", MultiTargetFilter_FilterProps, "Target: Props", true);
	AddMultiTargetFilter("@hunters", MultiTargetFilter_FilterHunters, "Target: Hunters", true);
	AddMultiTargetFilter("@hunter", MultiTargetFilter_FilterHunters, "Target: Hunters", true);
	
	RegAdminCmd("sm_setmodel", ConCmd_SetModel, ADMFLAG_CHEATS);
	
	AddCommandListener(CommandListener_Build, "build");
}

public bool MultiTargetFilter_FilterProps(const char[] pattern, ArrayList clients)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsPlayerProp(client))
			clients.Push(client);
	}
	
	return clients.Length > 0;
}

public bool MultiTargetFilter_FilterHunters(const char[] pattern, ArrayList clients)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsPlayerHunter(client))
			clients.Push(client);
	}
	
	return clients.Length > 0;
}

public Action ConCmd_SetModel(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setmodel <#userid|name> <model>");
		return Plugin_Handled;
	}
	
	char target[MAX_TARGET_LENGTH], model[PLATFORM_MAX_PATH];
	GetCmdArg(1, target, sizeof(target));
	GetCmdArg(2, model, sizeof(model));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(target, client, target_list, MaxClients + 1, COMMAND_TARGET_NONE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		SetCustomModel(target_list[i], model);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[PH] ", "%t", "Model Set", model, target_name);
	}
	else
	{
		ShowActivity2(client, "[PH] ", "%t", "Model Set", model, "_s", target_name);
	}
	
	return Plugin_Handled;
}

public Action CommandListener_Build(int client, const char[] command, int argc)
{
	if (argc < 1)
		return Plugin_Continue;
	
	if (TF2_GetPlayerClass(client) != TFClass_Engineer)
		return Plugin_Continue;
	
	char arg[8];
	GetCmdArg(1, arg, sizeof(arg));
	
	TFObjectType type = view_as<TFObjectType>(StringToInt(arg));
	
	// Prevent Engineers from building sentry guns
	if (type == TFObject_Sentry)
		return Plugin_Handled;
	
	return Plugin_Continue;
}