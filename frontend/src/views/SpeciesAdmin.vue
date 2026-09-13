<template>
  <div class="species-admin-page">
    <app-navbar :active="'speciesAdmin'" />

    <div class="admin-container">
      <div class="admin-header">
        <h1><i class="el-icon-s-grid"></i> 海洋生物信息管理</h1>
        <div class="header-actions">
          <el-button type="success" icon="el-icon-plus" @click="openAddDialog">新增物种</el-button>
          <el-button type="primary" icon="el-icon-monitor" @click="goDashboard">返回仪表盘</el-button>
        </div>
      </div>

      <!-- 物种类别切换 -->
      <el-tabs v-model="activeCategory" @tab-click="handleTabClick" class="category-tabs">
        <el-tab-pane label="鱼类" name="fish"></el-tab-pane>
        <el-tab-pane label="鲸类" name="whale"></el-tab-pane>
        <el-tab-pane label="无脊椎动物" name="invertebrate"></el-tab-pane>
      </el-tabs>

      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input
          v-model="searchName"
          placeholder="按名称搜索..."
          clearable
          style="width: 240px;"
          @keyup.enter.native="loadList"
          @clear="loadList"
        ></el-input>
        <el-button type="primary" icon="el-icon-search" @click="loadList">搜索</el-button>
        <el-button icon="el-icon-refresh" @click="resetSearch">重置</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table
        :data="tableData"
        v-loading="loading"
        border
        stripe
        style="width: 100%; margin-bottom: 20px;"
        :header-cell-style="{ background: '#1e3c72', color: '#fff' }"
      >
        <el-table-column prop="id" label="ID" width="70" align="center"></el-table-column>
        <el-table-column prop="name" label="名称" width="140"></el-table-column>
        <el-table-column prop="fishClass" label="纲" width="120"></el-table-column>
        <el-table-column prop="order" label="目" width="120"></el-table-column>
        <el-table-column prop="family" label="科" width="120"></el-table-column>
        <el-table-column v-if="activeCategory !== 'invertebrate'" prop="genus" label="属" width="100"></el-table-column>
        <el-table-column v-if="activeCategory === 'fish'" prop="scientificName" label="学名" width="140"></el-table-column>
        <el-table-column label="图片" width="100" align="center">
          <template slot-scope="scope">
            <el-image
              v-if="scope.row.imageUrl"
              :src="scope.row.imageUrl"
              :preview-src-list="[scope.row.imageUrl]"
              style="width: 50px; height: 50px;"
              fit="cover"
            ></el-image>
            <span v-else style="color: #ccc;">无</span>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" icon="el-icon-edit" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          :current-page="currentPage"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>

      <!-- 新增/编辑弹窗 -->
      <el-dialog
        :title="dialogTitle"
        :visible.sync="dialogVisible"
        width="600px"
        :close-on-click-modal="false"
      >
        <el-form ref="speciesForm" :model="formData" :rules="formRules" label-width="80px">
          <el-form-item label="名称" prop="name">
            <el-input v-model="formData.name" placeholder="请输入物种名称"></el-input>
          </el-form-item>
          <el-form-item label="纲" prop="fishClass">
            <el-input v-model="formData.fishClass" placeholder="请输入纲"></el-input>
          </el-form-item>
          <el-form-item label="目" prop="order">
            <el-input v-model="formData.order" placeholder="请输入目"></el-input>
          </el-form-item>
          <el-form-item label="科" prop="family">
            <el-input v-model="formData.family" placeholder="请输入科"></el-input>
          </el-form-item>
          <el-form-item v-if="activeCategory !== 'invertebrate'" label="属" prop="genus">
            <el-input v-model="formData.genus" placeholder="请输入属"></el-input>
          </el-form-item>
          <el-form-item v-if="activeCategory === 'fish'" label="学名" prop="scientificName">
            <el-input v-model="formData.scientificName" placeholder="请输入学名"></el-input>
          </el-form-item>
          <el-form-item label="图片URL" prop="imageUrl">
            <el-input v-model="formData.imageUrl" placeholder="请输入图片URL"></el-input>
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input type="textarea" :rows="4" v-model="formData.description" placeholder="请输入描述"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">确 定</el-button>
        </div>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';
import http from '@/utils/auth.js';

export default {
  name: 'SpeciesAdmin',
  components: { AppNavbar },
  data() {
    return {
      activeCategory: 'fish',
      searchName: '',
      tableData: [],
      loading: false,
      currentPage: 1,
      pageSize: 10,
      total: 0,
      dialogVisible: false,
      dialogTitle: '新增物种',
      isEdit: false,
      submitting: false,
      formData: {
        id: 0,
        name: '',
        fishClass: '',
        order: '',
        family: '',
        genus: '',
        scientificName: '',
        imageUrl: '',
        description: ''
      },
      formRules: {
        name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
        fishClass: [{ required: true, message: '请输入纲', trigger: 'blur' }],
        order: [{ required: true, message: '请输入目', trigger: 'blur' }],
        family: [{ required: true, message: '请输入科', trigger: 'blur' }]
      }
    };
  },
  mounted() {
    this.loadList();
  },
  methods: {
    async loadList() {
      this.loading = true;
      try {
        const res = await http.get(`/api/admin/species/${this.activeCategory}`, {
          params: {
            page: this.currentPage,
            size: this.pageSize,
            name: this.searchName || undefined
          }
        });
        if (res.data && res.data.code === 200 && res.data.data) {
          this.tableData = res.data.data.records || [];
          this.total = res.data.data.total || 0;
        } else {
          this.tableData = [];
          this.total = 0;
        }
      } catch (err) {
        if (err.response) {
          const status = err.response.status;
          if (status === 401) {
            // 401 已由拦截器处理（跳转登录）
          } else if (status === 403) {
            this.$message.error('权限不足，仅管理员可访问');
            this.$router.push('/index');
          } else {
            this.$message.error('加载数据失败');
          }
        } else {
          this.$message.error('网络异常，加载数据失败');
        }
        this.tableData = [];
        this.total = 0;
      } finally {
        this.loading = false;
      }
    },
    handleTabClick() {
      this.currentPage = 1;
      this.searchName = '';
      this.loadList();
    },
    handleSizeChange(size) {
      this.pageSize = size;
      this.currentPage = 1;
      this.loadList();
    },
    handleCurrentChange(page) {
      this.currentPage = page;
      this.loadList();
    },
    resetSearch() {
      this.searchName = '';
      this.currentPage = 1;
      this.loadList();
    },
    resetForm() {
      this.formData = {
        id: 0,
        name: '',
        fishClass: '',
        order: '',
        family: '',
        genus: '',
        scientificName: '',
        imageUrl: '',
        description: ''
      };
    },
    openAddDialog() {
      this.resetForm();
      this.isEdit = false;
      this.dialogTitle = `新增${this.categoryLabel()}`;
      this.dialogVisible = true;
    },
    openEditDialog(row) {
      this.formData = JSON.parse(JSON.stringify(row));
      this.isEdit = true;
      this.dialogTitle = `编辑${this.categoryLabel()}`;
      this.dialogVisible = true;
    },
    categoryLabel() {
      const map = { fish: '鱼类', whale: '鲸类', invertebrate: '无脊椎动物' };
      return map[this.activeCategory] || '物种';
    },
    handleSubmit() {
      this.$refs.speciesForm.validate(async (valid) => {
        if (!valid) return;
        this.submitting = true;
        try {
          const url = `/api/admin/species/${this.activeCategory}`;
          if (this.isEdit) {
            const res = await http.put(url, this.formData);
            if (res.data && res.data.code === 200) {
              this.$message.success('更新成功');
              this.dialogVisible = false;
              this.loadList();
            } else {
              this.$message.error(res.data.message || '更新失败');
            }
          } else {
            const res = await http.post(url, this.formData);
            if (res.data && res.data.code === 200) {
              this.$message.success('新增成功');
              this.dialogVisible = false;
              this.loadList();
            } else {
              this.$message.error(res.data.message || '新增失败');
            }
          }
        } catch (err) {
          if (err.response && err.response.status !== 401) {
            this.$message.error('操作失败');
          }
        } finally {
          this.submitting = false;
        }
      });
    },
    handleDelete(row) {
      this.$confirm(`确定要删除「${row.name}」吗？`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          const res = await http.delete(`/api/admin/species/${this.activeCategory}/${row.id}`);
          if (res.data && res.data.code === 200) {
            this.$message.success('删除成功');
            // 如果当前页只剩一条数据且不是第一页，回到上一页
            if (this.tableData.length === 1 && this.currentPage > 1) {
              this.currentPage--;
            }
            this.loadList();
          } else {
            this.$message.error(res.data.message || '删除失败');
          }
        } catch (err) {
          if (err.response && err.response.status !== 401) {
            this.$message.error('删除失败');
          }
        }
      }).catch(() => {});
    },
    goDashboard() {
      this.$router.push('/admin/dashboard');
    }
  }
};
</script>

<style scoped>
.species-admin-page {
  min-height: 100vh;
  background-image: url('/images/780.jpg');
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
}
.admin-container {
  max-width: 1400px;
  margin: 20px auto;
  padding: 24px;
  background-color: rgba(255, 255, 255, 0.85);
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 20px;
}
.admin-header h1 {
  margin: 0;
  color: #1e3c72;
  font-size: 26px;
}
.header-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}
.category-tabs {
  margin-bottom: 16px;
}
.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}
.pagination-wrapper {
  background-color: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-top: 20px;
  display: flex;
  justify-content: center;
}
</style>
