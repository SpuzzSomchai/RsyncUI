//
//  AddPostandPreView.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 01/04/2021.
//
// swiftlint:disable line_length

import SwiftUI

struct AddPostandPreView: View {
    @EnvironmentObject var rsyncUIdata: RsyncUIdata
    @EnvironmentObject var profilenames: Profilenames
    @Binding var selectedprofile: String?
    @Binding var reload: Bool

    enum PreandPostTaskField: Hashable {
        case pretaskField
        case posttaskField
    }

    @StateObject var newdata = ObserveablePreandPostTask()
    @FocusState private var focusField: PreandPostTaskField?

    var body: some View {
        Form {
            ZStack {
                HStack {
                    // For center
                    Spacer()

                    // Column 1
                    VStack(alignment: .leading) {
                        pretaskandtoggle

                        posttaskandtoggle

                        HStack {
                            if newdata.selectedconfig == nil { disablehaltshelltasksonerror } else {
                                ToggleViewDefault(NSLocalizedString("Halt on error", comment: ""), $newdata.haltshelltasksonerror)
                                    .onAppear(perform: {
                                        if newdata.selectedconfig?.haltshelltasksonerror == 1 {
                                            newdata.haltshelltasksonerror = true
                                        } else {
                                            newdata.haltshelltasksonerror = false
                                        }
                                    })
                            }
                        }
                    }
                    .padding()

                    // Column 2
                    VStack(alignment: .leading) {
                        ConfigurationsListSmall(selectedconfig: $newdata.selectedconfig.onChange {
                            newdata.updateview()
                        })

                        Spacer()
                    }
                    // For center
                    Spacer()
                }

                if newdata.updated == true { notifyupdated }
            }

            Spacer()

            VStack {
                HStack {
                    Spacer()

                    updatebutton
                }
            }
        }
        .lineSpacing(2)
        .padding()
        .onSubmit {
            switch focusField {
            case .pretaskField:
                focusField = .posttaskField
            case .posttaskField:
                newdata.enablepre = true
                newdata.enablepost = true
                newdata.haltshelltasksonerror = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    validateandupdate()
                }
                focusField = nil
            default:
                return
            }
        }
    }

    var updatebutton: some View {
        HStack {
            if newdata.selectedconfig == nil {
                Button("Update") {}
                    .buttonStyle(PrimaryButtonStyle())
            } else {
                if newdata.inputchangedbyuser == true {
                    Button("Update") { validateandupdate() }
                        .buttonStyle(PrimaryButtonStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 5)
                        )
                } else {
                    Button("Update") {}
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }

    var setpretask: some View {
        EditValue(250, NSLocalizedString("Add pretask", comment: ""), $newdata.pretask)
    }

    var setposttask: some View {
        EditValue(250, NSLocalizedString("Add posttask", comment: ""), $newdata.posttask)
    }

    var disablepretask: some View {
        ToggleViewDefault(NSLocalizedString("Enable", comment: ""), $newdata.enablepre)
    }

    var disableposttask: some View {
        ToggleViewDefault(NSLocalizedString("Enable", comment: ""), $newdata.enablepost)
    }

    var pretaskandtoggle: some View {
        VStack(alignment: .leading) {
            // Enable pretask
            if newdata.selectedconfig == nil { disablepretask } else {
                ToggleViewDefault(NSLocalizedString("Enable", comment: ""), $newdata.enablepre.onChange {
                    newdata.inputchangedbyuser = true
                })
                    .onAppear(perform: {
                        if newdata.selectedconfig?.executepretask == 1 {
                            newdata.enablepre = true
                        } else {
                            newdata.enablepre = false
                        }
                    })
            }

            // Pretask
            if newdata.selectedconfig == nil { setpretask } else {
                EditValue(250, nil, $newdata.pretask.onChange {
                    newdata.inputchangedbyuser = true
                })
                    .focused($focusField, equals: .pretaskField)
                    .textContentType(.none)
                    .submitLabel(.continue)
                    .onAppear(perform: {
                        if let task = newdata.selectedconfig?.pretask {
                            newdata.pretask = task
                        }
                    })
            }
        }
    }

    var posttaskandtoggle: some View {
        VStack(alignment: .leading) {
            // Enable posttask
            if newdata.selectedconfig == nil { disableposttask } else {
                ToggleViewDefault(NSLocalizedString("Enable", comment: ""), $newdata.enablepost.onChange {
                    newdata.inputchangedbyuser = true
                })
                    .onAppear(perform: {
                        if newdata.selectedconfig?.executeposttask == 1 {
                            newdata.enablepost = true
                        } else {
                            newdata.enablepost = false
                        }
                    })
            }

            // Posttask
            if newdata.selectedconfig == nil { setposttask } else {
                EditValue(250, nil, $newdata.posttask.onChange {
                    newdata.inputchangedbyuser = true
                })
                    .focused($focusField, equals: .posttaskField)
                    .textContentType(.none)
                    .submitLabel(.continue)
                    .onAppear(perform: {
                        if let task = newdata.selectedconfig?.posttask {
                            newdata.posttask = task
                        }
                    })
            }
        }
    }

    var disablehaltshelltasksonerror: some View {
        ToggleViewDefault(NSLocalizedString("Halt on error", comment: ""),
                          $newdata.haltshelltasksonerror.onChange {
                              newdata.inputchangedbyuser = true
                          })
    }

    var notifyupdated: some View {
        AlertToast(type: .complete(Color.green),
                   title: Optional(NSLocalizedString("Updated", comment: "")), subTitle: Optional(""))
    }

    var profile: String? {
        return rsyncUIdata.profile
    }

    var configurations: [Configuration]? {
        return rsyncUIdata.rsyncdata?.configurationData.getallconfigurations()
    }
}

extension AddPostandPreView {
    func validateandupdate() {
        newdata.validateandupdate(profile, configurations)
        reload = newdata.reload
        if newdata.updated == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                newdata.updated = false
            }
        }
    }
}
