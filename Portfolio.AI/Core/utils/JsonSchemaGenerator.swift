import Foundation

protocol JSONSchemaGeneratable: Codable {
    static func createSampleInstance() -> Self
    static func jsonSchema() -> String
}

extension JSONSchemaGeneratable {
    static func jsonSchema() -> String {
        let sample = createSampleInstance()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(sample)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return "{}"
            }
            
            // Transform sample values to type indicators
            let schema = transformToTypeSchema(jsonString: jsonString)
            return schema
            
        } catch {
            print("Failed to generate JSON schema for \(Self.self): \(error)")
            return "{}"
        }
    }
    
    private static func transformToTypeSchema(jsonString: String) -> String {
        var schema = jsonString
        
        // Replace common sample values with type indicators
        schema = schema.replacingOccurrences(of: "\"sample_string\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"SAMPLE_STRING\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"example\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"placeholder\"", with: "\"string\"")
        
        // Handle numbers (integers and doubles)
        schema = schema.replacingOccurrences(of: ": 0.0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 1.0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 1", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": -1", with: ": \"number\"")
        
        // Handle booleans
        schema = schema.replacingOccurrences(of: ": true", with: ": \"boolean\"")
        schema = schema.replacingOccurrences(of: ": false", with: ": \"boolean\"")
        
        // Handle dates (ISO format)
        let datePattern = ": \"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}[+-]\\d{4}\""
        schema = schema.replacingOccurrences(
            of: datePattern,
            with: ": \"date\"",
            options: .regularExpression
        )
        
        // Handle UUIDs
        let uuidPattern = ": \"[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\""
        schema = schema.replacingOccurrences(
            of: uuidPattern,
            with: ": \"uuid\"",
            options: .regularExpression
        )
        
        return schema
    }
}

// MARK: - Generic Schema Generator for any Codable
class JsonSchemaGenerator {
    
    /// Generates schema for any Codable type that conforms to JSONSchemaGeneratable
    static func generateSchema<T: JSONSchemaGeneratable>(for type: T.Type) -> String {
        return type.jsonSchema()
    }
    
    /// Convenience method to generate schema for Codable types without sample instance
    /// This method requires you to provide a sample instance
    static func generateSchema<T: Codable>(from sampleInstance: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(sampleInstance)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return "{}"
            }
            
            return transformToTypeSchema(jsonString: jsonString)
            
        } catch {
            print("Failed to generate JSON schema: \(error)")
            return "{}"
        }
    }
    
    private static func transformToTypeSchema(jsonString: String) -> String {
        var schema = jsonString
        
        // Replace common sample values with type indicators
        schema = schema.replacingOccurrences(of: "\"sample_string\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"SAMPLE_STRING\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"example\"", with: "\"string\"")
        schema = schema.replacingOccurrences(of: "\"placeholder\"", with: "\"string\"")
        
        // Handle numbers
        schema = schema.replacingOccurrences(of: ": 0.0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 1.0", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": 1", with: ": \"number\"")
        schema = schema.replacingOccurrences(of: ": -1", with: ": \"number\"")
        
        // Handle booleans
        schema = schema.replacingOccurrences(of: ": true", with: ": \"boolean\"")
        schema = schema.replacingOccurrences(of: ": false", with: ": \"boolean\"")
        
        // Handle dates
        let datePattern = ": \"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}[+-]\\d{4}\""
        schema = schema.replacingOccurrences(
            of: datePattern,
            with: ": \"date\"",
            options: .regularExpression
        )
        
        // Handle UUIDs
        let uuidPattern = ": \"[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\""
        schema = schema.replacingOccurrences(
            of: uuidPattern,
            with: ": \"uuid\"",
            options: .regularExpression
        )
        
        return schema
    }
}
