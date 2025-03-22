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
}


struct ContentView: View {
    @StateObject private var checklist = Checklist()
    
    @State private var input: String = ""

    var body: some View {
        VStack {
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
            
            
            Button(action: addNewItem) {
                Text("Add Item")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
