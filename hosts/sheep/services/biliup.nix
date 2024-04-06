{
  imports = [
    ../../../modules/servicy
  ];

  servicy.biliup = {
    enable = true;
    openFirewall = true;
    settings = {
      bili_force_source = true;
      streamers = {
        "络宝" = {
          url = [ "https://live.bilibili.com/32269170" ];
          tags = [ "v" ];
          title = "【络宝录播】{title}";
          credits = [
            { username = "络宝"; uid = "3546646881241985"; }
          ];
          description = ''
            {title} %Y-%m-%d %H:%M:%S
            {streamer} 主播直播间地址：{url}

            【@credit】
          '';
          tid = 27;
          copyright = 2;
        };
      };
    };
  };
}
