import SwiftUI


struct ChecklistItem {
    var title: String
    var isChecked: Bool
    
    init(title: String, isChecked: Bool) {
        self.title = title
        self.isChecked = isChecked
    }
}


class Checklist: ObservableObject {
    @Published var items: [ChecklistItem] = []
    
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
    
}


struct ContentView: View {
    @StateObject private var checklist = Checklist()
    
    @State private var input: String = ""

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
        }
        .padding()
    }
    
    func addNewItem() {
        let newItem = ChecklistItem(title: input, isChecked: false)
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
}

#Preview {
    ContentView()
}
