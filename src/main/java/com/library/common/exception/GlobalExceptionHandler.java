package com.library.common.exception;

import com.library.common.util.ResponseResult;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/**
 * 全局异常处理器（针对当前 ResponseResult.error 方法签名）
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 捕获所有未被其它 @ExceptionHandler 捕获的 Exception
     */
    @SneakyThrows
    @ExceptionHandler(Exception.class)
    public ResponseResult handleAllExceptions(HttpServletRequest request, Exception ex) {
        // 记录带堆栈的完整日志，方便定位
        log.error("请求 [{}] 时发生未知异常：", request.getRequestURI(), ex);
        // 返回通用的系统内部错误
        return ResponseResult.error(500, "系统内部错误，请联系管理员");
    }

    /**
     * 捕获所有 RuntimeException（会先匹配此方法，再看更具体的）
     */
    @SneakyThrows
    @ExceptionHandler(RuntimeException.class)
    public ResponseResult handleRuntimeException(HttpServletRequest request, RuntimeException ex) {
        log.warn("请求 [{}] 时出现运行时异常：{}", request.getRequestURI(), ex.getMessage());

        // 对常见的 RuntimeException 做更细致的区分
        if (ex instanceof IllegalArgumentException) {
            return ResponseResult.error(400, "参数错误：" + ex.getMessage());
        }
        if (ex instanceof NullPointerException) {
            return ResponseResult.error(500, "空指针异常，请检查代码逻辑");
        }
        // 默认返回：400 或 500 可按实际情况调整，这里统一返回 400
        return ResponseResult.error(400, ex.getMessage());
    }

    /**
     * 捕获 @RequestBody 参数解析失败（比如 JSON 格式有误，或缺少字段）
     */
    @SneakyThrows
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseResult handleHttpMessageNotReadable(HttpServletRequest request, HttpMessageNotReadableException ex) {
        log.error("请求 [{}] 时，HTTP 消息无法读取：{}", request.getRequestURI(), ex.getMessage());
        return ResponseResult.error(400, "请求体格式不正确，请检查 JSON 格式");
    }

    /**
     * 捕获表单字段绑定异常（如 @Valid 校验失败时抛出的 BindException）
     */
    @SneakyThrows
    @ExceptionHandler(BindException.class)
    public ResponseResult handleBindException(HttpServletRequest request, BindException ex) {
        String errorMsg = ex.getFieldErrors().stream()
                .findFirst()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .orElse("参数绑定异常");
        log.warn("请求 [{}] 时，参数绑定异常：{}", request.getRequestURI(), errorMsg);
        return ResponseResult.error(400, "参数校验失败：" + errorMsg);
    }

    /**
     * 捕获 @Valid 标注在 Controller 方法中、校验失败时抛出的 MethodArgumentNotValidException
     */
    @SneakyThrows
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseResult handleMethodArgumentNotValid(HttpServletRequest request, MethodArgumentNotValidException ex) {
        String errorMsg = ex.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .orElse("参数校验失败");
        log.warn("请求 [{}] 时，方法参数校验失败：{}", request.getRequestURI(), errorMsg);
        return ResponseResult.error(400, "参数校验失败：" + errorMsg);
    }


}
