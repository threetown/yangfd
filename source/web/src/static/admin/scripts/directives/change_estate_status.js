/* Created by frank on 14-9-15. */
angular.module('app')
    .directive('changeEstateStatus', function (estateApi, estateStatus, userApi) {
        return {
            restrict: 'AE',
            templateUrl: '/static/admin/templates/change_estate_status.tpl.html',
            replace: false,
            scope: {
                item: '=ngModel'
            },
            link: function ($scope, elm, attrs) {
                var user = userApi.getCurrentUser()
                if (!user) { return }
                var roles = user.role
                if (_.contains(roles, 'admin') || _.contains(roles, 'jr_admin')) {
                    $scope.estateStatus = estateStatus
                } else if (_.contains(roles, 'developer') || _.contains(roles, 'agency')) {
                    $scope.estateStatus = estateStatus.filter(function (one, index, array) {
                        return one.value === 'selling' ||
                            one.value === 'hidden' ||
                            one.value === 'sold out' ||
                            one.value === $scope.item.status
                    })
                } else {
                    $scope.estateStatus = estateStatus.filter(function (one, index, array) {
                        return one.value === $scope.item.status
                    })
                }
                $scope.onUpdateStatus = function (item, newStatus) {
                    estateApi.update({id: item.id, status: newStatus}, {successMessage: '增加权限操作成功', errorMessage: true})
                        .success(function () {
                            item.status = newStatus
                        })
                }
            }
        }
    })
