import Foundation
import SwiftUI

enum EnumScheduleTypePicker: String, CaseIterable, Identifiable, CustomStringConvertible {
    case once
    case daily
    case weekly

    var id: String { rawValue }
    var description: String { rawValue.localizedCapitalized }
}

struct ScheduleDatePicker: View {
    @Binding var selecteddate: Date

    var body: some View {
        VStack(alignment: .center) {
            DatePicker("", selection: $selecteddate,
                       in: Date()...,
                       displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(FieldDatePickerStyle())
                .labelsHidden()
        }
    }
}
