local Constants = {
	NotificationKeys = {
		MultipleBundleNoticeKey = "InGame.InspectMenu.Description.MultipleBundlesNotice",
		SingleBundleNoticeKey = "InGame.InspectMenu.Description.SingleBundleNotice",
		LimitedItemNoticeKey = "InGame.InspectMenu.Description.LimitedNotice",
	},

	ItemType = {
		Asset = "Asset",
		Bundle = "Bundle",
	},

	View = {
		Compact = 0,
		Wide = 1,
		WideLandscape = 2,
	},

	HumanoidDescriptionAssetNames = {
		BackAccessory = "BackAccessory",
		FaceAccessory = "FaceAccessory",
		FrontAccessory = "FrontAccessory",
		HairAccessory = "HairAccessory",
		HatAccessory = "HatAccessory",
		NeckAccessory = "NeckAccessory",
		ShouldersAccessory = "ShouldersAccessory",
		WaistAccessory = "WaistAccessory",
		Face = "Face",
		Head = "Head",
		LeftArm = "LeftArm",
		LeftLeg = "LeftLeg",
		RightArm = "RightArm",
		RightLeg = "RightLeg",
		Torso = "Torso",
		GraphicTShirt = "GraphicTShirt",
		Pants = "Pants",
		Shirt = "Shirt",
		ClimbAnimation = "ClimbAnimation",
		FallAnimation = "FallAnimation",
		IdleAnimation = "IdleAnimation",
		JumpAnimation = "JumpAnimation",
		RunAnimation = "RunAnimation",
		SwimAnimation = "SwimAnimation",
		WalkAnimation = "WalkAnimation",
	},

	HumanoidDescriptionIdToName = {
		["2"]  = "Shirt",
		["8"]  = "HatAccessory",
		["41"] = "HairAccessory",
		["42"] = "FaceAccessory",
		["43"] = "NeckAccessory",
		["44"] = "ShouldersAccessory",
		["45"] = "FrontAccessory",
		["46"] = "BackAccessory",
		["47"] = "WaistAccessory",
		["11"] = "Shirt",
		["12"] = "Pants",
		["19"] = "Gear",
		["17"] = "Head",
		["18"] = "Face",
		["27"] = "Torso",
		["28"] = "RightArm",
		["29"] = "LeftArm",
		["30"] = "LeftLeg",
		["31"] = "RightLeg",
		["48"] = "ClimbAnimation",
		["50"] = "FallAnimation",
		["51"] = "IdleAnimation",
		["52"] = "JumpAnimation",
		["53"] = "RunAnimation",
		["54"] = "SwimAnimation",
		["55"] = "WalkAnimation",
	},

	AnimationAssetTypes = {
		["48"] = 48,
		["50"] = 50,
		["51"] = 51,
		["52"] = 52,
		["53"] = 53,
		["54"] = 54,
		["55"] = 55,
		["61"] = 61, -- Emotes
	},
}

return Constants