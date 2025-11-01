class SecretWriter {
    [string] $Alias
    [string] $Name
    [string] $Secret

    SecretWriter([string] $alias, [string] $name, [string] $secret) {
        $this.Alias = $alias
        $this.Name = $name
        $this.Secret = $secret
    }

    [string] GetAlias() {
        return $this.Alias
    }
}
