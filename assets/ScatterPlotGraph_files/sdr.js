function __sdr(id) {
		this.sid = id ;
		this.track = function track(activity,module,org,user) {
			var org_name, org_fid, org_dn;
			if (null != org) {
				if ("string" == typeof org) {
					org_name = org;
					org_fid = null;
					org_dn = null;
				} else {
					org_name = org['o'] || null;
					org_fid = org['ofid'] || null;
					org_dn = org['odn'] || null;
				}
			}	
			org_name = encodeURIComponent(org_name || this.getOrg());
			org_fid = encodeURIComponent(org_fid || this.getOrgId());
			org_dn = encodeURIComponent(org_dn || this.getOrgDisplayName());
			user = encodeURIComponent(user || this.getUser());	
			activity = encodeURIComponent(activity);
			module = encodeURIComponent(module);
			var proto = (("https:" == document.location.protocol) ? "https://" : "http://");
			var img = new Image();
			img.src = proto + "sdr.totango.com/pixel.gif/?sdr_s="+this.sid+"&sdr_o="+org_name+"&sdr_ofid="+org_fid+"&sdr_u="+user+"&sdr_a="+activity+"&sdr_m="+module+"&sdr_odn="+org_dn+"&r="+Math.random();
			return img;
		}
		this.identify = function identify(org, user) {
			var org_name, org_fid, org_dn;
			if ("string" == typeof org) {
				org_name = org;
				org_fid = null;
				org_dn = null;
			} else {
				org_name = org['o'] || null;
				org_fid = org['ofid'] || null;
				org_dn = org['odn'] || null;
			}
			this.savecookie("totango.org_name",org_name,1);
			this.savecookie("totango.org_ofid", org_fid,1 );
			this.savecookie("totango.org_dn", org_dn,1 )
			this.savecookie("totango.user",user,1);
		}
		this.getOrgId = function getOrgId() {
			return this.readcookie("totango.org_ofid");
		}
		this.getOrgDisplayName = function getOrgDisplayName() {
			return this.readcookie("totango.org_dn");
		}
		this.getOrg = function getOrg() {
			return this.readcookie("totango.org_name"); 
		}
		this.getUser = function getUser() {
			return this.readcookie("totango.user");
		}
		this.savecookie = function savecookie(name, value, days) {
			var date = new Date();
			date.setTime(date.getTime()+( ((typeof(days) != "undefined") ? days : 3)*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
			document.cookie = name+"="+value+expires+"; path=/";
		}
		this.readcookie = function readcookie(name) {
			var re=new RegExp("(?:^| )"+name+"=([^;]*)","i");
			var matches = document.cookie.match(re);
			return(matches && matches.length==2) ? matches[1] : null;
		}
	}	