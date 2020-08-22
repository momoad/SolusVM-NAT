<link href="modules/addons/solusvm_nat/static/css/jquery-confirm.css" rel="stylesheet">
<script src="modules/addons/solusvm_nat/static/js/jquery-confirm.js"></script>
<div class="row">
    <div class="loading">
        <h1 style="text-align:center;color: #8f8f8f;font-weight: 500;font-size: 48px">
            <i class="fa fa-refresh fa-spin"></i> 请稍后 , 正在加载数据
        </h1>
    </div>
    <div class="nat-body" style="display:none">
        <div class="col-xs-12">
            <div class="row">
                <div class="form-group">
                    <label>请选择需要操作的服务</label>
                </div>
                <div class="row">
                    <div class="col-md-3 col-xs-12">
                        <div class=" list-group" id="service-list"></div>
                    </div>
                    <div class="col-md-9 col-xs-12">
                        <div class="panel panel-default" id="service-panel-placeholder">
                            <div class="panel-body">
                                请从左边/上边选取服务
                            </div>
                        </div>
                        <div class="panel panel-default" id="service-panel-loading" style="display:none">
                            <h1 style="text-align:center;color: #8f8f8f;font-weight: 500;font-size: 48px">
                                <i class="fa fa-refresh fa-spin"></i> 请稍后 , 正在加载数据
                            </h1>
                        </div>
                        <div class="panel panel-default" id="service-panel" style="display:none">
                            <div class="panel-heading">
                                <h3 class="panel-title">端口映射列表</h3>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-10 col-xs-12">
                                        <label>最大可映射端口数量</label>
                                        <div class="progress" style="margin-bottom: 0px;">
                                            <div class="progress-bar" role="progressbar" style="min-width: 3em;">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-2 col-xs-12" style="margin-top: 10px;">
                                        <button type="button" class="btn btn-primary" >添加规则
                                            <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover table-bordered table-striped">
                                    <thead>
                                        <tr>
                                            <th>内网IP</th>
                                            <th>内网端口</th>
                                            <th>方向</th>
                                            <th>公网IP</th>
                                            <th>公网端口</th>
                                            <th>协议</th>
                                            <th>状态</th>
                                            <th>动作</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>192.168.1.1</td>
                                            <td>123</td>
                                            <td>=></td>
                                            <td>1.1.1.1</td>
                                            <td>123</td>
                                            <td>TCP</td>
                                            <td>test</td>
                                            <td>
                                                <button type="button" class="btn btn-danger">Delete
                                                    <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                                                </button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<style>
    .nat-body,
    .nat-body button {
        font-family: Microsoft YaHei Light, Microsoft YaHei;
    }
</style>

<script type="text/javascript">
    $.ajax({
        url: 'index.php?m=solusvm_nat&ajax=true',
        data: {
            action: 'list_services'
        }
    }).done(function (data) {
            if (data.result == 'error'){
                $(".loading h1").html(data.error)
                return false;
            }
            $('.loading').css('display', 'none')
            $('.nat-body').css('display', '')
            data.data.forEach(function (services) {
                $('#service-list').append('<a href="#" class="list-group-item" data-serviceid="' + services.serviceid + '"><h4 class="list-group-item-heading">' + services.hostname + '</h4><p class="list-group-item-text">' + services.productgroupname + ' - ' + services.productname + '</p></a>')
            })
            $('#service-list').on('click', 'a', function () {
                $(this).siblings().removeClass('active')
                $(this).addClass('active')
                $('#service-panel-placeholder').css('display', 'none')
                $('#service-panel').css('display', 'none')
                $('#service-panel-loading').css('display', '')
                $('#service-panel').data('serviceid', $(this).data('serviceid'))
                $.ajax({
                    url: 'index.php?m=solusvm_nat&ajax=true',
                    data: {
                        action: 'list_service_port',
                        serviceid: $(this).data('serviceid')
                    }
                })
                    .done(function (data) {
                        if (data.result != 'success'){
                            $(".loading h1").html(data.error)
                            return false;
                        }
                        $('#service-panel-loading').css('display', 'none')
                        let portPrecent = data.rules.length / data.maximum_port * 100 + '%'
                        $('#service-panel .progress .progress-bar').width(portPrecent).text(data.rules.length + ' / ' + data.maximum_port)
                        $('#service-panel table tbody').empty()
                        if (data.rules.length > 0) {
                            $('#service-panel .table-responsive').css('display', '')
                        } else {
                            $('#service-panel .table-responsive').css('display', 'none')
                        }
                        data.rules.forEach(function (rule) {
                            switch(rule.status){
                                case "pending":
                                    rule.status = '<span class="label label-warning"><i class="fa fa-cog fa-spin"></i> 创建中</span>'
                                    break;
                                case "created":
                                    rule.status = '<span class="label label-success">已创建</span>'
                                    break;
                                case "deleting":
                                    rule.status = '<span class="label label-danger"><i class="fa fa-cog fa-spin"></i> 删除中</span>'
                                    break;
                            }
                            $('#service-panel table tbody').append('<tr id="rule-' + rule.id + '"></tr>')
                            $('#rule-' + rule.id).append('<td>' + rule.ip + '</td>')
                            $('#rule-' + rule.id).append('<td>' + rule.port + '</td>')
                            $('#rule-' + rule.id).append('<td>=></td>')

                            var public_address = rule.public_ip
                            if (rule.cname !== undefined){
                                public_address = rule.public_ip + "<br/>" + rule.cname
                            }
                            $('#rule-' + rule.id).append('<td>' + public_address + '</td>')
                            $('#rule-' + rule.id).append('<td>' + rule.public_port + '</td>')
                            $('#rule-' + rule.id).append('<td>' + rule.port_type + '</td>')
                            $('#rule-' + rule.id).append('<td>' + rule.status + '</td>')
                            $('#rule-' + rule.id).append('<td><button type="button" class="btn btn-xs btn-danger" data-ruleid="' + rule.id + '" data-rule-string="' + rule.ip + ':' + rule.port + '=>' + rule.public_ip + ':' + rule.public_port + '/' + rule.port_type + '">删除 <span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button></td>')
                        })
                        $('#service-panel').css('display', '')
                    })
            })
            $('#service-panel .panel-body').on('click', 'button', function () {
                var serviceid = $('#service-panel').data('serviceid')
                $.confirm({
                    title: '添加规则',
                    content: '' +
                        '<form action="" class="formName">' +
                        '<div class="form-group">' +
                        '<div class="input-group">' +
                        '<input type="number" class="form-control" name="in_port" min="1" max="65535" placeholder="内网端口"><div class="input-group-btn">' +
                        '<button style="border-top-right-radius: 0;border-bottom-right-radius: 0;border-top-left-radius: 0;border-bottom-left-radius: 0;margin-left: 1px;" class="btn btn-default disabled" type="button">=&gt;</button>' +
                        '</div><input type="number" class="form-control" name="out_port" min="1" max="65535" placeholder="外网端口"></div>' +
                        '<div class="form-group"><label>协议</label><select name="type" class="form-control"><option value="tcp">TCP</option><option value="udp">UDP</option></select></div>' +
                        '</div>' +
                        '</form>',
                    buttons: {
                        formSubmit: {
                            text: '提交',
                            btnClass: 'btn-blue',
                            action: function () {
                                var in_port = this.$content.find('[name=in_port]').val();
                                var out_port = this.$content.find('[name=out_port]').val();
                                var port_type = this.$content.find('[name=type]').val();
                                console.log(port_type)
                                if (!in_port || !out_port) {
                                    $.alert('端口范围错误');
                                    return false;
                                }


                                $.confirm({
                                    content: function () {
                                        var self = this;
                                        return $.ajax({
                                            url: 'index.php?m=solusvm_nat&ajax=true&action=add_port_forward&serviceid=' + serviceid + '&in=' + in_port + "&out=" + out_port + "&type=" + port_type,
                                            dataType: 'json',
                                        }).done(function (response) {
                                            if (response.result == "success") {
                                                self.setType('green')
                                                self.setTitle('成功');
                                                self.setContent('添加成功');
                                                $('#service-list a[data-serviceid="' + serviceid + '"]').click()
                                            } else {
                                                self.setType('red')
                                                self.setTitle('错误');
                                                self.setContent(response.error);
                                            }

                                        }).fail(function () {
                                            self.setType('red')
                                            self.setTitle('错误');
                                            self.setContent('与服务器通讯时出现错误, 请重试.');
                                        });
                                    }
                                });
                            }
                        },
                        cancel: {
                            text: '取消',
                        }
                    },
                    onContentReady: function () {
                        var jc = this;
                        this.$content.find('form').on('submit', function (e) {
                            e.preventDefault();
                            jc.$$formSubmit.trigger('click');
                        });
                    }
                });
            })
            $('#service-panel table tbody').on('click', 'button', function () {
                var serviceid = $('#service-panel').data('serviceid')
                var ruleid = $(this).data('ruleid')
                $.confirm({
                    title: '确认删除转发规则',
                    content: '即将删除 <br/>' + $(this).data('rule-string') + '<br/>该转发规则',
                    buttons: {
                        confirm: {
                            text: '确认',
                            btnClass: 'btn-blue',
                            action: function () {
                                $.confirm({
                                    content: function () {
                                        var self = this;
                                        return $.ajax({
                                            url: 'index.php?m=solusvm_nat&ajax=true&action=delete_port_forward&ruleid=' + ruleid,
                                            dataType: 'json',
                                        }).done(function (response) {
                                            if (response.result == "success") {
                                                self.setType('green')
                                                self.setTitle('成功');
                                                self.setContent('删除成功');
                                                $('#service-list a[data-serviceid="' + serviceid + '"]').click()
                                            } else {
                                                self.setType('red')
                                                self.setTitle('错误');
                                                self.setContent(response.error);
                                            }

                                        }).fail(function () {
                                            self.setType('red')
                                            self.setTitle('错误');
                                            self.setContent('与服务器通讯时出现错误, 请重试.');
                                        });
                                    }
                                });
                            }
                        },
                        cancel: {
                            text: "取消"
                        },
                    }
                });
            })
        }).fail(function(){
            $(".loading h1").html("与服务器通讯时出现错误, 请稍后再试")
        })

</script>
