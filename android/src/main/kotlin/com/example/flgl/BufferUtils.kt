package com.example.flgl

import java.nio.*

object BufferUtils {

    val BYTES_PER_FLOAT = 4
    val BYTES_PER_SHORT = 2

    fun createFloatBuffer(array: FloatArray): FloatBuffer {
        val buffer = ByteBuffer
                .allocateDirect(array.size * BYTES_PER_FLOAT)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()

        buffer.put(array);
        buffer.position(0);
        return buffer
    }

    fun createShortBuffer(array: ShortArray): ShortBuffer {
        val buffer = ByteBuffer
                .allocateDirect(array.size * BYTES_PER_SHORT)
                .order(ByteOrder.nativeOrder())
                .asShortBuffer()

        buffer.put(array)
        return buffer
    }

    fun createByteBuffer(array: ByteArray): ByteBuffer {
        val buffer = ByteBuffer
                .allocateDirect(array.size * BYTES_PER_SHORT)
                .order(ByteOrder.nativeOrder())

        buffer.put(array)
        return buffer
    }

}