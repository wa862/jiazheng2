// 基于百度地图 JS SDK 的通用定位封装
// 使用前请在 .env 中配置 VITE_BAIDU_MAP_AK=你的百度AK

let baiduMapLoadingPromise = null

function loadBaiduMapScript(ak) {
  if (window.BMap && typeof window.BMap.Map === 'function') {
    return Promise.resolve(window.BMap)
  }

  if (baiduMapLoadingPromise) {
    return baiduMapLoadingPromise
  }

  baiduMapLoadingPromise = new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = `https://api.map.baidu.com/api?v=3.0&ak=${ak}&callback=__baiduMapInitCallback`

    window.__baiduMapInitCallback = () => {
      resolve(window.BMap)
      delete window.__baiduMapInitCallback
    }

    script.onerror = (err) => {
      console.error('百度地图脚本加载失败', err)
      reject(new Error('百度地图脚本加载失败'))
    }

    document.head.appendChild(script)
  })

  return baiduMapLoadingPromise
}

export async function getCurrentLocationByBaidu() {
  const ak = import.meta.env.VITE_BAIDU_MAP_AK
  if (!ak) {
    throw new Error('未配置百度地图 AK（VITE_BAIDU_MAP_AK）')
  }

  const BMap = await loadBaiduMapScript(ak)

  return new Promise((resolve, reject) => {
    try {
      const geolocation = new BMap.Geolocation()
      geolocation.getCurrentPosition(
        function (r) {
          if (this.getStatus() === window.BMAP_STATUS_SUCCESS) {
            const point = r.point
            const gc = new BMap.Geocoder()
            gc.getLocation(point, (res) => {
              const comp = res.addressComponents || {}
              const fullAddress = res.address || ''
              resolve({
                latitude: point.lat,
                longitude: point.lng,
                province: comp.province || '',
                city: comp.city || '',
                district: comp.district || '',
                street: comp.street || '',
                streetNumber: comp.streetNumber || '',
                fullAddress
              })
            })
          } else {
            reject(new Error('定位失败，请稍后重试'))
          }
        },
        { enableHighAccuracy: true }
      )
    } catch (e) {
      console.error('获取当前位置失败', e)
      reject(new Error('获取当前位置失败，请稍后重试'))
    }
  })
}

