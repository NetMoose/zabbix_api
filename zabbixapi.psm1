    class ZabbixAPI {
        #zabbix server ip or name
        [string] $zabbix_server 
        [boolean] $debug


        $query = @{
            jsonrpc="2.0"
            id=1
            method=""
            auth=$null
        }

        #Constructor
        ZabbixAPI([string]$proto,[string]$server,[string]$user,[string]$password,[boolean]$debug) {
            if($server){
                if($proto)
                {
                    $this.zabbix_server = "{0}://{1}/api_jsonrpc.php" -f $proto,$server
                } else {
                    $this.zabbix_server = "http://{0}/api_jsonrpc.php" -f $server
                }
                
            } else {
                Write-Error -Message  'Not found zabbix server name!' -ErrorAction Stop
            }
            if($debug){
                $this.debug = $debug
            } else {
                $this.debug = $false
            }
            if ($user -and $password){
                $this.query.method='user.login'
                $a = $this.SendQueryToZabbix(@{user=$user;password=$password})
                if(!$a){
                    $this.query.auth = $null
                    Write-Error -Message 'Not logged!' -ErrorAction Stop
                } else {
                    $this.query.auth = $a[0]
                }
            } else {
                $this.query.auth = $null
            }
        }

        [array]SendQueryToZabbix([hashtable]$params){
            $ret = @()
            $this.query.id = $this.query.id + 1
            if($this.query.params) {
                $this.query.PsObject.properties.remove('params')
            }
            $this.query|Add-Member -Name 'params' -Value $params -MemberType NoteProperty
            $JSON = $this.query|ConvertTo-Json -Compress -Depth 100
            if($this.debug){
                Write-Host "Send -> $JSON" -ForegroundColor DarkGray
            }
            $Response = Invoke-RestMethod -Method Post -Body $JSON -Uri $this.zabbix_server -ContentType "application/json-rpc"
            if($Response.error){
                Write-Error -Message $Response.error -ErrorAction Stop
            } else {
                $ret = $Response.result
            }
            return $ret
        }
    }
