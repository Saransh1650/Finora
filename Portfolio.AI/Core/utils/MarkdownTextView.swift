import SwiftUI

struct MarkdownTextView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseMarkdownLines(text), id: \.id) { line in
                line.view
            }
        }
    }
    
    private func parseMarkdownLines(_ text: String) -> [MarkdownLine] {
        let lines = text.components(separatedBy: .newlines)
        return lines.enumerated().compactMap { index, line in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { return nil }
            
            return MarkdownLine(id: index, view: parseMarkdownLine(trimmedLine))
        }
    }
    
    private func parseMarkdownLine(_ line: String) -> AnyView {
        if line.hasPrefix("**") && line.hasSuffix("**") && line.count > 4 {
            // Handle standalone bold headers like **Portfolio Summary**
            let content = String(line.dropFirst(2).dropLast(2))
            return AnyView(
                Text(content)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)
            )
        } else if line.hasPrefix("*   ") {
            // Handle bullet points like *   **Quantity:** 4.0 shares
            let content = String(line.dropFirst(4))
            return AnyView(
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .fontWeight(.medium)
                    parseInlineMarkdown(content)
                    Spacer()
                }
                .padding(.leading, 8)
            )
        } else {
            // Handle regular text with potential inline bold formatting
            return AnyView(
                parseInlineMarkdown(line)
                    .multilineTextAlignment(.leading)
            )
        }
    }
    
    private func parseInlineMarkdown(_ text: String) -> Text {
        // Use regex to find **text** patterns for bold formatting
        let pattern = #"\*\*([^*]+?)\*\*"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            var result = Text("")
            var lastEnd = 0
            
            for match in matches {
                // Add normal text before the bold part
                if match.range.location > lastEnd {
                    let normalText = nsString.substring(with: NSRange(
                        location: lastEnd,
                        length: match.range.location - lastEnd
                    ))
                    result = result + Text(normalText)
                }
                
                // Add the bold text (content between **)
                let boldText = nsString.substring(with: match.range(at: 1))
                result = result + Text(boldText)
                    .fontWeight(.bold)
                
                lastEnd = match.range.location + match.range.length
            }
            
            // Add remaining normal text after the last match
            if lastEnd < nsString.length {
                let remainingText = nsString.substring(from: lastEnd)
                result = result + Text(remainingText)
            }
            
            // If no matches found, return the original text
            return result
            
        } catch {
            print("Markdown parsing error: \(error)")
            // Fallback to plain text if regex fails
            return Text(text)
        }
    }
}

struct MarkdownLine {
    let id: Int
    let view: AnyView
}
