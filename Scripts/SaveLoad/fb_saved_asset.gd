class_name FB_SavedAsset extends Resource

# Represents a persistent "Asset" object in a saved Fishbowl level.

@export var asset_file_path: String
@export var asset_transform: Transform3D
@export var object_ID: int = -1


static func serialize_asset(asset: FB_AssetBase) -> FB_SavedAsset:
	var saved_asset := FB_SavedAsset.new()
	saved_asset.asset_file_path = asset.asset_file_path
	saved_asset.asset_transform = asset.get_child(0).global_transform
	saved_asset.object_ID = asset.object_ID
	return saved_asset


static func deserialize_asset(saved_asset: FB_SavedAsset) -> FB_AssetBase:
	var asset: FB_AssetBase = load(saved_asset.asset_file_path).instantiate()
	asset.transform = saved_asset.asset_transform
	asset.asset_file_path = saved_asset.asset_file_path
	asset.object_ID = saved_asset.object_ID
	return asset
