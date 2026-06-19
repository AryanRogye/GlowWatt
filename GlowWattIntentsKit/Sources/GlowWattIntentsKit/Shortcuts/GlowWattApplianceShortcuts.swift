import AppIntents

public struct GlowWattApplianceShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BestTimeToRunAppliancesIntent(),
            phrases: [
                "What is the best time to run appliances in \(.applicationName)",
                "Should I run appliances now in \(.applicationName)",
                "When should I run appliances in \(.applicationName)",
                "When should I run my dishwasher in \(.applicationName)"
            ],
            shortTitle: "Run Appliances",
            systemImageName: "washer.fill"
        )
    }
}
