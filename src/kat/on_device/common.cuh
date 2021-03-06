/**
 * @file on_device/common.cuh Some basic type and constant definitions used by all device-side CUDA-related code
 * in this directory; possibly imported from `cuda-api-wrappers`.
 *
 */
#pragma once
#ifndef CUDA_KAT_ON_DEVICE_COMMON_CUH_
#define CUDA_KAT_ON_DEVICE_COMMON_CUH_

#include <type_traits>
#include <climits> // for CHAR_BIT
#include <cuda_runtime_api.h>

namespace kat {

/**
 * CUDA kernels are launched in grids of blocks of threads, in 3 dimensions.
 * In each of these, the numbers of blocks per grid is specified in this type.
 *
 * @note Theoretically, CUDA could split the type for blocks per grid and
 * threads per block, but for now they're the same.
 *
 * @note All three dimensions in dim3 are of the same type as dim3::x
 */
using grid_dimension_t = decltype(dim3::x);

/**
 * CUDA kernels are launched in grids of blocks of threads, in 3 dimensions.
 * In each of these, the number of threads per block is specified in this type.
 *
 * @note Theoretically, CUDA could split the type for blocks per grid and
 * threads per block, but for now they're the same.
 */
using grid_block_dimension_t  = grid_dimension_t;

using native_word_t = unsigned; // TODO: Make this uint32_t perhaps?
enum : native_word_t { warp_size = 32 };
enum : native_word_t { log_warp_size = 5 };

/**
 * @brief a size type no smaller than a native word.
 *
 * Sometimes, in device code, we only need our size type to cover a small
 * range of values; but - it is still more effective to use a full native word,
 * rather than to risk extra instructions to enforce the limits of
 * sub-native-word values. And while it's true this might not help much,
 * or be optimized away - let's be on the safe side anyway.
 */
template <typename Size>
using promoted_size_t = typename std::common_type<Size, native_word_t>::type;

 /**
  * A mask with one bit for each lane in a warp. Used to indicate which threads
  * meet a certain criterion or need to have some action applied to them.
  *
  * @todo: Consider using a 32-bit bit field
  */
using lane_mask_t = unsigned;

enum : lane_mask_t {
	full_warp_mask  = 0xFFFFFFFF, //!< Bits turned on for all lanes in thw warp
	empty_warp_mask = 0x0,        //!< Bits turned on for all lanes in thw warp
};


/**
 * The number bits in the representation of a value of type T.
 *
 * @note with this variant, you'll need to manually specify the type.
 */
template <typename T>
constexpr std::size_t size_in_bits() { return sizeof(T) * CHAR_BIT; }

/**
 * The number bits in the representation of a value of type T
 *
 * @note with this variant, the type will be deduced from the
 * object you pass.
 */
template <typename T>
constexpr std::size_t size_in_bits(const T&) { return sizeof(T) * CHAR_BIT; }


} // namespace kat


///@cond
#include <kat/define_specifiers.hpp>
///@endcond

//constexpr __fhd__ bool operator==(const dim3& lhs, const dim3& rhs)
//{
//	return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z;
//}


///@cond
#include <kat/undefine_specifiers.hpp>
///@endcond


#endif // CUDA_KAT_ON_DEVICE_COMMON_CUH_
