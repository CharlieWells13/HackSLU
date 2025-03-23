import SwiftUI


struct ChecklistItem: Codable, Identifiable{
    var id = UUID()
    var title: String
    var isChecked: Bool
    var hasTime: Bool
    var time: Date?
    
    init(title: String, isChecked: Bool, time: Date? = nil, hasTime: Bool) {
        self.title = title
        self.isChecked = isChecked
        self.time = time
        self.hasTime = hasTime
    }
}

class Checklist: ObservableObject {
    @Published var items: [ChecklistItem] = []{
        didSet{
            saveItems()
        }
    }
    
    private let storageKey = "ChecklistItems"
    
    init(){
        loadItems()
    }
    
    func addItem(newItem: ChecklistItem) {
        items.append(newItem)
    }
    
    func checkCompleted() -> Int {
        var counter = 0
        for item in items {
            if item.isChecked {
                counter += 1
            }
        }
        return counter
    }
    
    func clearItems() {
        for i in items.indices {
            items[i].isChecked = false
        }
    }
    
    func saveItems(){
        if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decodedItems = try? JSONDecoder().decode([ChecklistItem].self, from: savedData) {
            items = decodedItems
        }
    }
    
}


struct ContentView: View {
    @State private var isRecording = false

    @StateObject private var checklist = Checklist()
    
    @State private var input: String = ""
    
    @State private var selectedDate: Date = Date()
    
    @State private var isTimed: Bool = false


    var body: some View {
        VStack {
            
            let total: Int = checklist.items.count
            let complete: Int = checklist.checkCompleted()
            Text("Progress: \(complete) / \(total)")
            
            List{
                ForEach(checklist.items, id: \.title) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        if item.hasTime, let time = item.time {
                            Text("Due: \(time, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(time < Date() ? .red : .gray)  // Change color based on comparison
                        }
                        else {
                            Text("") // Empty text if time is nil
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isChecked ? .green : .gray)
                            .onTapGesture {
                                toggleCheck(item: item)
                            }
                        
                        
                    }
                    
                }
                .onDelete(perform: delete)
            }
            
            TextField("Enter Task", text: $input)
                .foregroundColor(.black)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                .padding(.horizontal)
            
            HStack {
                Text("Timed Item?")
                Toggle("", isOn: $isTimed)
                    .labelsHidden()
            }
                        
    
            if isTimed {
                DatePicker("Select Time", selection: $selectedDate)
            }
            
            
            HStack{
                
                Button(action: addNewItem) {
                    Text("Add Item")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: checklist.clearItems) {
                    Text("Clear")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                /*Button(action: checklist.importItems) {
                 Text("Import")
                 .padding()
                 .background(Color.green)
                 .foregroundColor(.white)
                 .cornerRadius(10)
                 }
                 */
            }
            VStack(spacing: 20) {
                Text("Microphone Audio Capture")
                    .font(.title)
                
                Button(action: {
                    if isRecording {
                        MicrophoneAudioCapture.shared.stopCapturing()
                    } else {
                        MicrophoneAudioCapture.shared.startCapturing()
                    }
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                }
                
                Button("Play Recording") {
                    MicrophoneAudioCapture.shared.playRecording()
                }
                .padding()
            }
            .padding()
        }
        
    }
    func addNewItem() {
        let newItem = ChecklistItem(title: input, isChecked: false, time: selectedDate == Date() ? nil : selectedDate, hasTime: isTimed)
        checklist.addItem(newItem: newItem)
        input = ""
    }
    
    func toggleCheck(item: ChecklistItem) {
        if let index = checklist.items.firstIndex(where: { $0.title == item.title }) {
            checklist.items[index].isChecked.toggle()
        }
    }
    
    func delete(at offsets: IndexSet) {
        checklist.items.remove(atOffsets: offsets)
    }
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }
}

#Preview {
    ContentView()
}
