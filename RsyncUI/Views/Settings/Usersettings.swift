//
//  Usersettings.swift
//  RsyncSwiftUI
//
//  Created by Thomas Evensen on 10/02/2021.
//
// swiftlint:disable line_length

import AlertToast
import SwiftUI

struct Usersettings: View {
    @EnvironmentObject var rsyncversionObject: GetRsyncversion
    @StateObject var usersettings = ObserveableUsersetting()
    @State private var backup = false

    var body: some View {
        Form {
            ZStack {
                HStack {
                    // For center
                    Spacer()

                    // Column 1
                    VStack(alignment: .leading) {
                        Section(header: headerrsync) {
                            ToggleView(NSLocalizedString("Rsync ver 3.x", comment: ""), $usersettings.rsyncversion3.onChange {
                                rsyncversionObject.update(usersettings.rsyncversion3)
                            })

                            // Only preset localpath for rsync if locapath is set. If default values either in /usr/bin or
                            // /usr/local/bin set as placeholder value to present path
                            if usersettings.localrsyncpath.isEmpty == true {
                                setrsyncpathdefault
                            } else {
                                setrsyncpathlocalpath
                            }
                        }

                        Section(header: headerpathforrestore) {
                            setpathforrestore
                        }
                    }.padding()

                    // Column 2
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Section(header: headerloggingtofile) {
                                    ToggleView(NSLocalizedString("None", comment: ""), $usersettings.nologging.onChange {
                                        if usersettings.nologging == true {
                                            usersettings.minimumlogging = false
                                            usersettings.fulllogging = false
                                        } else {
                                            usersettings.minimumlogging = true
                                            usersettings.fulllogging = false
                                        }
                                    })

                                    ToggleView(NSLocalizedString("Min", comment: ""), $usersettings.minimumlogging.onChange {
                                        if usersettings.minimumlogging == true {
                                            usersettings.nologging = false
                                            usersettings.fulllogging = false
                                        }
                                    })

                                    ToggleView(NSLocalizedString("Full", comment: ""), $usersettings.fulllogging.onChange {
                                        if usersettings.fulllogging == true {
                                            usersettings.nologging = false
                                            usersettings.minimumlogging = false
                                        }
                                    })
                                }
                            }

                            VStack(alignment: .leading) {
                                Section(header: headerdetailedlogging) {
                                    ToggleView(NSLocalizedString("Detailed", comment: ""), $usersettings.detailedlogging)
                                }

                                Section(header: headermarkdays) {
                                    setmarkdays
                                }
                            }
                        }
                    }.padding()

                    // Column 3
                    VStack(alignment: .leading) {
                        Section(header: headerothersettings) {
                            ToggleView(NSLocalizedString("Monitor network", comment: ""), $usersettings.monitornetworkconnection)

                            ToggleView(NSLocalizedString("Check data", comment: ""), $usersettings.checkinput)
                        }
                    }
                    .padding()

                    // For center
                    Spacer()
                }

                if backup == true {
                    AlertToast(type: .complete(Color.green),
                               title: Optional(NSLocalizedString("Saved", comment: "")), subTitle: Optional(""))
                        .onAppear(perform: {
                            // Show updated for 1 second
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                backup = false
                            }
                        })
                }
            }

            // Save button right down corner
            Spacer()

            HStack {
                Spacer()

                // Backup configuration files
                Button("Backup") { backupuserconfigs() }
                    .buttonStyle(PrimaryButtonStyle())

                Button("Save") { saveusersettings() }
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .lineSpacing(2)
        .padding()
    }

    // Rsync
    var headerrsync: some View {
        Text("Rsync version and path")
    }

    var setrsyncpathlocalpath: some View {
        EditValue(250, nil, $usersettings.localrsyncpath)
            .onAppear(perform: {
                usersettings.localrsyncpath = SetandValidatepathforrsync().getpathforrsync()
            })
    }

    var setrsyncpathdefault: some View {
        EditValue(250, SetandValidatepathforrsync().getpathforrsync(), $usersettings.localrsyncpath)
    }

    // Restore path
    var headerpathforrestore: some View {
        Text("Path for restore")
    }

    var setpathforrestore: some View {
        EditValue(250, NSLocalizedString("Path for restore", comment: ""), $usersettings.temporarypathforrestore)
            .onAppear(perform: {
                if let pathforrestore = SharedReference.shared.pathforrestore {
                    usersettings.temporarypathforrestore = pathforrestore
                }
            })
    }

    // Logging
    var headerloggingtofile: some View {
        Text("Log to file")
    }

    // Detail of logging
    var headerdetailedlogging: some View {
        Text("Level log")
    }

    // Header other settings
    var headerothersettings: some View {
        Text("Other settings")
    }

    // Header user setting
    var headerusersetting: some View {
        Text("Save settings")
    }

    // Header backup
    var headermarkdays: some View {
        Text("Mark days")
    }

    var setmarkdays: some View {
        TextField(String(SharedReference.shared.marknumberofdayssince),
                  text: $usersettings.marknumberofdayssince)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 70)
            .lineLimit(1)
    }
}

extension Usersettings {
    func saveusersettings() {
        _ = WriteUserConfigurationPLIST()
    }

    func backupuserconfigs() {
        _ = Backupconfigfiles()
        backup = true
    }
}
