/* Created by frank on 14-9-17. */


(function () {

    function ctrlPropertyList($scope, $state, enumApi,fctModal, $timeout, api) {
//        enumApi.getEnumsByType('news_category').success(function (data) {
//            $scope.newsCategoryList = data.val
//        })
        $scope.list = []
        $scope.perPage = 12
        $scope.currentPageNumber = 1
        $scope.pages = []
        $scope.api = api

        var params = {
            per_page: $scope.perPage
        }

        api.getAll({ params: params }).success(onGetList)

        $scope.refreshList = function () {
            api.getAll({ params: params}).success(onGetList)
        }

        $scope.onSearch = function (searchText) {
            params.phone = searchText || undefined
            delete params.time
            delete params.register_time
            delete params.insert_time

            api.search({params: params, errorMessage: true}).success(onGetList)
        }

        $scope.onRemove = function (item) {
            fctModal.show('Do you want to remove it?', undefined, function () {
                api.remove(item.id).success(function () {
                    $scope.list.splice($scope.list.indexOf(item), 1)
                })
            })
        }

        $scope.nextPage = function () {
            var lastItem = $scope.list[$scope.list.length - 1]
            if (lastItem.time) {params.time = lastItem.time}
            if (lastItem.register_time) {params.register_time = lastItem.register_time}
            if (lastItem.insert_time) {params.insert_time = lastItem.insert_time}

            api.getAll({params: params})
                .success(function () {
                    $scope.currentPageNumber += 1
                })
                .success(onGetList)

        }
        $scope.prevPage = function () {

            var prevPrevPageNumber = $scope.currentPageNumber - 2
            var prevPrevPageData
            var lastItem
            if (prevPrevPageNumber >= 1) {
                prevPrevPageData = $scope.pages[prevPrevPageNumber]
                lastItem = prevPrevPageData[prevPrevPageData.length - 1]
            }

            if (lastItem) {
                if (lastItem.time) {params.time = lastItem.time}
                if (lastItem.register_time) {params.register_time = lastItem.register_time}
                if (lastItem.insert_time) {params.insert_time = lastItem.insert_time}
            } else {
                delete params.time
                delete params.register_time
                delete params.insert_time
            }

            api.getAll({params: params})
                .success(function () {
                    $scope.currentPageNumber -= 1
                })
                .success(onGetList)

        }

        function onGetList(data) {
            $scope.fetched = true
            $scope.list = data.val.content
            $scope.pages[$scope.currentPageNumber] = $scope.list

            if (!$scope.list || $scope.list.length < $scope.perPage) {
                $scope.noNext = true
            } else {
                $scope.noNext = false
            }
            if ($scope.currentPageNumber <= 1) {
                $scope.noPrev = true
            } else {
                $scope.noPrev = false
            }
        }

    }

    angular.module('app').controller('ctrlPropertyList', ctrlPropertyList)

})()


