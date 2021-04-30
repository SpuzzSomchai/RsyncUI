//
//  SnapshotsView.swift
//  RsyncSwiftUI
//
//  Created by Thomas Evensen on 23/02/2021.
//

import SwiftUI

struct SnapshotsView: View {
    @EnvironmentObject var rsyncUIData: RsyncUIdata
    @StateObject var snapshotdata = SnapshotData()
    @Binding var selectedconfig: Configuration?

    @State private var snapshotrecords: Logrecordsschedules?
    @State private var selecteduuids = Set<UUID>()
    // Not used but requiered in parameter
    @State private var inwork = -1
    @State private var selectable = false
    // If not a snapshot
    @State private var notsnapshot = false
    // Hold your horses
    // Cannot collect remote cataloglist for more than one task a timw
    @State private var gettingdata = false

    var body: some View {
        VStack {
            ConfigurationsList(selectedconfig: $selectedconfig.onChange { getdata() },
                               selecteduuids: $selecteduuids,
                               inwork: $inwork,
                               selectable: $selectable)

            Spacer()

            ZStack {
                SnapshotListView(selectedconfig: $selectedconfig,
                                 snapshotrecords: $snapshotrecords,
                                 selecteduuids: $selecteduuids)
                    .environmentObject(snapshotdata)
                    .onDeleteCommand(perform: { delete() })

                if snapshotdata.state == .getdata { RotatingDotsIndicatorView()
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(.red)
                }
            }
        }

        if notsnapshot == true { notasnapshottask }
        if gettingdata == true { gettingdatainprocess }
        if snapshotdata.numlocallogrecords != snapshotdata.numremotecatalogs { discrepancy }

        HStack {
            Text(label)

            Spacer()

            Button(NSLocalizedString("Tag", comment: "Tag")) { tagsnapshots() }
                .buttonStyle(PrimaryButtonStyle())

            Button(NSLocalizedString("Select", comment: "Select button")) { select() }
                .buttonStyle(PrimaryButtonStyle())

            Button(NSLocalizedString("Delete", comment: "Delete")) { delete() }
                .buttonStyle(AbortButtonStyle())

            Button(NSLocalizedString("Abort", comment: "Abort button")) { abort() }
                .buttonStyle(AbortButtonStyle())
        }
    }

    var label: String {
        NSLocalizedString("Number of logs", comment: "") + ": " + "\(snapshotdata.numremotecatalogs)"
    }

    var notasnapshottask: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1))
            Text(NSLocalizedString("Not a snapshot task", comment: "settings"))
                .font(.title3)
                .foregroundColor(Color.blue)
        }
        .frame(width: 200, height: 20, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 2))
    }

    var gettingdatainprocess: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1))
            Text(NSLocalizedString("In process in getting data", comment: "settings"))
                .font(.title3)
                .foregroundColor(Color.blue)
        }
        .frame(width: 200, height: 20, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 2))
    }

    var discrepancy: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1))
            Text(NSLocalizedString("some discrepancy", comment: "settings"))
                .font(.title3)
                .foregroundColor(Color.blue)
        }
        .frame(width: 200, height: 20, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 2))
    }
}

extension SnapshotsView {
    func abort() {
        snapshotdata.state = .start
        snapshotdata.setsnapshotdata(nil)
        // kill any ongoing processes
        _ = InterruptProcess()
    }

    func getdata() {
        guard SharedReference.shared.process == nil else {
            gettingdata = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                gettingdata = false
            }
            return
        }
        if let config = selectedconfig {
            guard config.task == SharedReference.shared.snapshot else {
                notsnapshot = true
                // Show added for 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    notsnapshot = false
                }
                return
            }
            if rsyncUIData.profile != "test" {
                _ = Snapshotlogsandcatalogs(config: config,
                                            configurationsSwiftUI: rsyncUIData.rsyncdata?.configurationData,
                                            schedulesSwiftUI: rsyncUIData.rsyncdata?.scheduleData,
                                            snapshotdata: snapshotdata,
                                            test: false)
            } else {
                _ = Snapshotlogsandcatalogs(config: config,
                                            configurationsSwiftUI: rsyncUIData.rsyncdata?.configurationData,
                                            schedulesSwiftUI: rsyncUIData.rsyncdata?.scheduleData,
                                            snapshotdata: snapshotdata,
                                            test: true)
            }
        }
    }

    func tagsnapshots() {
        if let config = selectedconfig {
            guard config.task == SharedReference.shared.snapshot else { return }
            guard (snapshotdata.getsnapshotdata()?.count ?? 0) > 0 else { return }
            let tagged = TagSnapshots(plan: config.snaplast ?? 0,
                                      snapdayoffweek: config.snapdayoffweek ?? "",
                                      data: snapshotdata.getsnapshotdata())
            snapshotdata.setsnapshotdata(tagged.logrecordssnapshot)
        }
    }

    func select() {
        if let log = snapshotrecords {
            if selecteduuids.contains(log.id) {
                selecteduuids.remove(log.id)
            } else {
                selecteduuids.insert(log.id)
            }
        }
    }

    func delete() {
        // Send all selected UUIDs to mark for delete
        _ = NotYetImplemented()
    }
}

/*
 TODO:
 - function for delete
 - there is a bug in collecting many snapshot logs, a mixup of snapshotnums and logs
 - add plan for snapshots week or monthly
 - REMOVE test when done
 */
