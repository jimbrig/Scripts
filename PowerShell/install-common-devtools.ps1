# tools we expect devs across many scenarios will want

cinst git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
cinst poshgit oh-my-posh gh vscode-insiders rapidee linkshellextension nvm python3 ngrok.portable winaero-tweaker 7zip.install autohotkey.install 

choco install -y 
choco install -y poshgit
choco install -y oh-my-posh
choco install -y peco
choco install -y gh
choco install -y kdiff3
choco install -y SourceTree
choco install -y jetbrainstoolbox
choco install -y vscode
choco install -y notepadplusplus
choco install -y nodejs
choco install -y FiraCode
choco install -y jetbrainsmono //see how to get the jetbrainsmono NF, Nerd Font version https://github.com/ryanoasis/nerd-fonts
choco install -y sysinternals
choco install -y ngrok.portable
choco install -y fiddler
choco install -y winscp
choco install -y rapidee
choco install -y snoop

Install-Module -Force oh-my-posh