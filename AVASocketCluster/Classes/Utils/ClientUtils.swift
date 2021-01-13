class ClientUtils {
    
    public static func getAuthToken(message: Any?) -> String? {
        guard let items = message as? [String: Any] else { return nil }
        guard let data = items["data"] as? [String: Any] else { return nil }
        
        return data["token"] as? String
    }
    
    public static func getIsAuthenticated(message: Any?) -> Bool? {
        guard let items = message as? [String: Any] else { return nil }
        guard let data = items["data"] as? [String: Any] else { return nil }
        
        return data["isAuthenticated"] as? Bool
    }
    
}
