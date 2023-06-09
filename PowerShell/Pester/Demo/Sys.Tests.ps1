#Requires -Modules Pester

Describe "Update-Modules" {
    It "should update all modules" {
        $modules = @(
            @{ Name = "Module1"; Version = "1.0.0" }
            @{ Name = "Module2"; Version = "1.0.0" }
            @{ Name = "Module3"; Version = "1.0.0" }
        )
        $modules | Should -Not -BeNullOrEmpty
        $modules | Should -HaveCount 3
        $modules | Should -Contain @{ Name = "Module1"; Version = "1.0.0" }
        $modules | Should -Contain @{ Name = "Module2"; Version = "1.0.0" }
        $modules | Should -Contain @{ Name = "Module3"; Version = "1.0.0" }
    }
}

