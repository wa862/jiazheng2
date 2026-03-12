package com.jiazheng.config;

import com.jiazheng.entity.Worker;
import com.jiazheng.mapper.WorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class WorkerDataInitializer implements CommandLineRunner {

    @Autowired
    private WorkerRepository workerRepository;

    @Override
    public void run(String... args) throws Exception {
        if (workerRepository.count() == 0) {
            List<Worker> workers = new ArrayList<>();

            // 保洁服务 - 女性阿姨
            workers.add(createWorker("张阿姨", "13800001001", "F", 45, 8, 35.0, 4.8, "专业保洁8年，擅长深度清洁、玻璃清洁、厨房油污清理", 1));
            workers.add(createWorker("李阿姨", "13800001002", "F", 42, 6, 32.0, 4.7, "细心负责，服务态度好，客户满意度高", 1));
            workers.add(createWorker("王阿姨", "13800001003", "F", 48, 10, 38.0, 4.9, "经验丰富，工作认真，口碑极佳", 1));
            workers.add(createWorker("刘阿姨", "13800001004", "F", 40, 5, 30.0, 4.6, "年轻有活力，干活麻利，效率高", 1));
            workers.add(createWorker("陈阿姨", "13800001005", "F", 46, 7, 36.0, 4.8, "专业保洁，注重细节，客户评价好", 1));

            // 月嫂服务 - 女性阿姨
            workers.add(createWorker("赵月嫂", "13800002001", "F", 38, 6, 120.0, 4.9, "专业月嫂，持有月嫂证书，经验丰富", 2));
            workers.add(createWorker("孙月嫂", "13800002002", "F", 42, 8, 130.0, 5.0, "金牌月嫂，服务过50+家庭，口碑极佳", 2));
            workers.add(createWorker("周月嫂", "13800002003", "F", 40, 7, 125.0, 4.8, "专业护理，细心周到，宝妈放心", 2));
            workers.add(createWorker("吴月嫂", "13800002004", "F", 36, 5, 115.0, 4.7, "年轻月嫂，学习能力强，服务贴心", 2));
            workers.add(createWorker("郑月嫂", "13800002005", "F", 44, 9, 135.0, 4.9, "资深月嫂，经验丰富，客户信赖", 2));

            // 护理服务 - 男女混合
            workers.add(createWorker("冯师傅", "13800003001", "M", 35, 5, 80.0, 4.7, "专业护理师，持有护理证书，服务贴心", 3));
            workers.add(createWorker("卫阿姨", "13800003002", "F", 42, 7, 85.0, 4.8, "经验丰富，耐心细致，患者家属满意", 3));
            workers.add(createWorker("蒋师傅", "13800003003", "M", 40, 6, 82.0, 4.7, "专业护理，责任心强，服务周到", 3));
            workers.add(createWorker("沈阿姨", "13800003004", "F", 38, 5, 78.0, 4.6, "细心护理，态度亲切，患者喜欢", 3));
            workers.add(createWorker("韩师傅", "13800003005", "M", 45, 8, 88.0, 4.9, "资深护理师，经验丰富，专业可靠", 3));

            // 钟点工 - 男女混合
            workers.add(createWorker("杨师傅", "13800004001", "M", 32, 4, 45.0, 4.6, "年轻力壮，干活麻利，效率高", 4));
            workers.add(createWorker("朱阿姨", "13800004002", "F", 38, 6, 48.0, 4.7, "经验丰富，工作认真，客户好评", 4));
            workers.add(createWorker("秦师傅", "13800004003", "M", 35, 5, 46.0, 4.6, "专业钟点工，服务态度好", 4));
            workers.add(createWorker("许阿姨", "13800004004", "F", 40, 7, 50.0, 4.8, "经验丰富，细心负责，口碑好", 4));
            workers.add(createWorker("何师傅", "13800004005", "M", 38, 6, 47.0, 4.7, "专业服务，效率高，客户满意", 4));

            workerRepository.saveAll(workers);
            System.out.println("已初始化 " + workers.size() + " 位家政人员数据");
        }
    }

    private Worker createWorker(String name, String phone, String gender, Integer age, 
                                Integer experience, Double price, Double rating, 
                                String description, Integer categoryId) {
        Worker worker = new Worker();
        worker.setName(name);
        worker.setPhone(phone);
        worker.setGender(gender);
        worker.setAge(age);
        worker.setExperience(experience);
        worker.setPrice(price);
        worker.setRating(rating);
        worker.setDescription(description);
        worker.setCategoryId(categoryId);
        worker.setStatus("available");
        return worker;
    }
}
